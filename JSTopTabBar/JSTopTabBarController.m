//
//  JSTopTabBarController.m
//  JSTopTabBar
//
//  Created by Josh Sklar on 5/14/13.
//  Copyright (c) 2013 Josh Sklar. All rights reserved.
//

#import "JSTopTabBarController.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static const CGFloat kTabBarHeight = 70.;
static const CGFloat kStatusBarHeight = 20;

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

typedef enum {
    JSTTBTopTabBarExposed,
    JSTTBTopTabBarNotExposed
} JSTTBTopTabBarPosition;

typedef enum {
    JSTTBMoveDirectionUp,
    JSTTBMoveDirectionDown,
    JSTTBMoveDirectionRight,
    JSTTBMoveDirectionLeft
} JSTTBMoveDirection;

@interface JSTopTabBarController ()
{
@private
    JSTTBTopTabBarPosition topTabBarPosition;
}

/* private methods */
- (void)didTapToggleTopTabBar:(id)sender;
- (void)didTapTopTabBarButton:(id)sender;
- (void)move:(UIView*)view direction:(JSTTBMoveDirection)direction by:(NSInteger)amount withDuration:(NSTimeInterval)duration completionBlock:(void (^)(BOOL finished))block;
- (void)partialFade:(UIView*)view finalAlpha:(CGFloat)alpha withDuration:(NSTimeInterval)duration completionBlock:(void (^)(BOOL finished))block;
- (void)didPanToggleTopBarButton:(id)sender;
- (void)didTapOverlay:(id)sender;

/* Array of all of the buttons contained in the JSTopTabBar */
@property (strong, nonatomic) NSMutableArray *topTabBarButtons;

/* Used for the toggle top tab bar button */
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@property(nonatomic,copy) NSArray *viewControllers;

/* The active view controller */
@property (strong, nonatomic) UIViewController *mainViewController;

@property (strong, nonatomic) UIView *overlay;

@end

@implementation JSTopTabBarController

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super init];
    if (self) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, self.view.frame.size.width, kTabBarHeight);
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor grayColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
        
        self.viewControllers = viewControllers;
        
        self.mainViewController = [self.viewControllers objectAtIndex:0];
        
        NSInteger numVCs = self.viewControllers.count;
        
        NSInteger xPos = 0;
        NSInteger btnWidth = self.view.frame.size.width / numVCs;
        
        NSInteger i = 0;
        
        self.topTabBarButtons = [[NSMutableArray alloc]initWithCapacity:viewControllers.count];
        
        for (UIViewController *vc in self.viewControllers) {
            [vc setTopTabBar:self];
            vc.view.frame = self.view.bounds;
            
            JSTopTabBarButton *b = [[JSTopTabBarButton alloc]initWithFrame:CGRectMake(xPos, 0, btnWidth, kTabBarHeight)];
            [b setTitle:[NSString stringWithFormat:@"%i", i]];
            b.tag = i;
            [b addTarget:self action:@selector(didTapTopTabBarButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:b];
            
            [self.topTabBarButtons addObject:b];
            
            xPos += btnWidth;
            i++;
        }
        
        self.selectedIndex = 0;
        
        [self.view addSubview:self.mainViewController.view];
        
        self.overlay = [[UIView alloc]initWithFrame:self.view.bounds];
        [self.overlay setBackgroundColor:[UIColor blackColor]];
        [self.overlay setAlpha:0.];
        UITapGestureRecognizer *tappedOverlay = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOverlay:)];
        [self.overlay addGestureRecognizer:tappedOverlay];
        
        [self.mainViewController.view addSubview:self.overlay];
        
        self.toggleTopTabBar = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 52, 0, 36, 52)];
        self.toggleTopTabBar.layer.shadowColor = [UIColor blackColor].CGColor;
        self.toggleTopTabBar.layer.shadowRadius = 10.;
        self.toggleTopTabBar.layer.shadowOpacity = 0.5;
        [self.toggleTopTabBar addTarget:self action:@selector(didTapToggleTopTabBar:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
        [self.toggleTopTabBar setBackgroundImage:[UIImage imageNamed:@"menu_button_image"] forState:UIControlStateNormal];
        [self.view addSubview:self.toggleTopTabBar];
        [self.view bringSubviewToFront:self.toggleTopTabBar];
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPanToggleTopBarButton:)];
        
        [self.toggleTopTabBar addGestureRecognizer:self.panGestureRecognizer];
        
        topTabBarPosition = JSTTBTopTabBarNotExposed;
    }
    return self;
}

- (void)setTitles:(NSArray *)titles
{
    NSAssert(titles.count == self.topTabBarButtons.count, @"Number of titles was not equal to the number of top tab bar buttons");
    
    for (JSTopTabBarButton *b in self.topTabBarButtons) {
        [b setTitle:[titles objectAtIndex:b.tag]];
    }
}

- (void)setImages:(NSArray*)imageNames
{
    NSAssert(imageNames.count == self.topTabBarButtons.count, @"Number of titles was not equal to the number of top tab bar buttons");
    
    for (UIButton *b in self.topTabBarButtons) {
        [b setBackgroundImage:[UIImage imageNamed:[imageNames objectAtIndex:b.tag]] forState:UIControlStateNormal];
    }
}

- (void)setActiveViewController:(UIViewController*)viewController
{
    for (UIViewController *vc in self.viewControllers) {
        if (vc == viewController) {
            [self.mainViewController.view removeFromSuperview];
            self.mainViewController = vc;
            [self.view addSubview:self.mainViewController.view];
            [self.view bringSubviewToFront:self.toggleTopTabBar];
            return;
        }
    }
    NSAssert(NO, @"View controller passed to setActiveViewController was not in self.viewControllers");
}

- (void)setBadgeNumber:(UIViewController*)viewController badgeNumber:(NSUInteger)badgeNum
{
    int i = 0;
    for (UIViewController *vc in self.viewControllers) {
        if (vc == viewController) {
            JSTopTabBarButton *b = (JSTopTabBarButton*)[self.topTabBarButtons objectAtIndex:i];
            [b setBadgeNumber:badgeNum];
            return;
        }
        i++;
    }
    
    NSAssert(NO, @"View controller passed to setBadgeNumber was not in self.viewControllers");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Internal methods

- (void)didTapToggleTopTabBar:(id)sender
{
    static CGFloat animationDuration = 0.2;
    
    switch (topTabBarPosition) {
        case JSTTBTopTabBarNotExposed:
            /* move the main view controller and the toggle button down */
            [self move:self.mainViewController.view direction:JSTTBMoveDirectionDown by:kTabBarHeight withDuration:animationDuration completionBlock:nil];
            [self move:self.toggleTopTabBar direction:JSTTBMoveDirectionDown by:kTabBarHeight withDuration:animationDuration completionBlock:nil];
            topTabBarPosition = JSTTBTopTabBarExposed;
            [self.mainViewController.view bringSubviewToFront:self.overlay];
            [self partialFade:self.overlay finalAlpha:0.7 withDuration:animationDuration completionBlock:nil];
            break;
        default:
            /* move the main view controller and the toggle button up */
            [self move:self.mainViewController.view direction:JSTTBMoveDirectionUp by:kTabBarHeight withDuration:animationDuration completionBlock:nil];
            [self move:self.toggleTopTabBar direction:JSTTBMoveDirectionUp by:kTabBarHeight withDuration:animationDuration completionBlock:nil];
            topTabBarPosition = JSTTBTopTabBarNotExposed;
            [self partialFade:self.overlay finalAlpha:0. withDuration:animationDuration completionBlock:nil];
            break;
    }
}

- (void)didTapTopTabBarButton:(id)sender
{
    UIButton *b = (UIButton*)sender;
    
    self.selectedIndex = b.tag;
    
    [self.mainViewController.view removeFromSuperview];
    
    UIViewController *nextViewController = [self.viewControllers objectAtIndex:b.tag];
    nextViewController.view.frame = self.mainViewController.view.frame;
    
    self.mainViewController = nextViewController;
    
    [self.overlay removeFromSuperview];
    [self.mainViewController.view addSubview:self.overlay];
    
    [self.view addSubview:self.mainViewController.view];
    [self.view bringSubviewToFront:self.toggleTopTabBar];
    
    [self didTapToggleTopTabBar:nil];
}

#pragma mark - Helper methods

- (void)move:(UIView*)view direction:(JSTTBMoveDirection)direction by:(NSInteger)amount withDuration:(NSTimeInterval)duration completionBlock:(void (^)(BOOL finished))block
{
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         switch (direction) {
                             case JSTTBMoveDirectionUp:
                                 [view setCenter:CGPointMake(view.center.x, view.center.y-amount)];
                                 /* rotate it 180 degrees */
                                 self.toggleTopTabBar.transform = CGAffineTransformMakeRotation(M_PI*2);
                                 break;
                             case JSTTBMoveDirectionDown:
                                 /* rotate it 180 degrees */
                                 self.toggleTopTabBar.transform = CGAffineTransformMakeRotation(M_PI);
                                 [view setCenter:CGPointMake(view.center.x, view.center.y+amount)];
                                 break;
                             case JSTTBMoveDirectionLeft:
                                 [view setCenter:CGPointMake(view.center.x - amount, view.center.y)];
                                 break;
                             case JSTTBMoveDirectionRight:
                                 [view setCenter:CGPointMake(view.center.x + amount, view.center.y)];
                                 break;
                             default:
                                 break;
                         }
                     }
                     completion:block];
}

- (void)partialFade:(UIView*)view finalAlpha:(CGFloat)alpha withDuration:(NSTimeInterval)duration completionBlock:(void (^)(BOOL finished))block
{
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [view setAlpha:alpha];
                     }
                     completion:block];
}

- (void)didPanToggleTopBarButton:(id)sender
{
    UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer*)sender;
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        UIView *draggedButton = recognizer.view;
        CGPoint translation = [recognizer translationInView:self.view];
        
        CGRect newButtonFrame = draggedButton.frame;
        newButtonFrame.origin.x += translation.x;
        newButtonFrame.origin.y += translation.y;
        
        // allow dragging on the edges of the screen
        if (newButtonFrame.origin.x <= 0)
            newButtonFrame.origin.x = 0;
        if (newButtonFrame.origin.y <= self.mainViewController.view.frame.origin.y)
            newButtonFrame.origin.y = self.mainViewController.view.frame.origin.y;
        
        if (newButtonFrame.origin.x + newButtonFrame.size.width >= kScreenWidth)
            newButtonFrame.origin.x = kScreenWidth - newButtonFrame.size.width;
        if (newButtonFrame.origin.y + newButtonFrame.size.height >= kScreenHeight - kStatusBarHeight)
            newButtonFrame.origin.y = kScreenHeight - newButtonFrame.size.height - kStatusBarHeight;
        
        draggedButton.frame = newButtonFrame;
        
        [recognizer setTranslation:CGPointZero inView:self.view];
    }
    else if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        CGPoint translatedPoint = self.toggleTopTabBar.frame.origin;
        
        CGFloat yPos = translatedPoint.y;
        CGFloat xPos = translatedPoint.x;
        
        CGFloat halfwayPointY = [UIScreen mainScreen].bounds.size.height/2;
        CGFloat halfwayPointX = [UIScreen mainScreen].bounds.size.width/2;
        
        CGFloat yDistance, xDistance;
        CGFloat finalY, finalX;
        
        // find the distance to the closer y edge
        if (yPos > halfwayPointY) {
            yDistance = [UIScreen mainScreen].bounds.size.height - yPos;
            finalY = [UIScreen mainScreen].bounds.size.height - self.toggleTopTabBar.frame.size.height - kStatusBarHeight;
        }
        else {
            yDistance = yPos;
            finalY = self.mainViewController.view.frame.origin.y;
        }
        // find distance to closer x edge
        if (xPos > halfwayPointX) {
            xDistance = [UIScreen mainScreen].bounds.size.width - xPos;
            finalX = [UIScreen mainScreen].bounds.size.width - self.toggleTopTabBar.frame.size.width;
        }
        else {
            xDistance = xPos;
            finalX = 0;
        }
        
        CGFloat animationDuration = 0.1;
        
        [UIView animateWithDuration:animationDuration
                              delay:0.
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             UIView *v = [sender view];
                             if (xDistance < yDistance) {
                                 [v setFrame:CGRectMake(finalX, v.frame.origin.y, v.frame.size.width, v.frame.size.height)];
                             }
                             else {
                                 [v setFrame:CGRectMake(v.frame.origin.x, finalY, v.frame.size.width, v.frame.size.height)];
                             }
                         } completion:nil];
    }
}


- (void)didTapOverlay:(id)sender
{
    [self didTapToggleTopTabBar:nil];
}

@end

@implementation UIViewController (JSTopTabBarItem)

@dynamic topTabBar;

static const char* topTabBarKey = "TopTabBarKey";

- (JSTopTabBarController*)topTabBar_core {
    return objc_getAssociatedObject(self, topTabBarKey);
}

- (JSTopTabBarController*)topTabBar {
    id result = [self topTabBar_core];
    return result;
}

- (void)setTopTabBar:(JSTopTabBarController *)topTabBar {
    objc_setAssociatedObject(self, topTabBarKey, topTabBar, OBJC_ASSOCIATION_ASSIGN);
}

@end

@implementation JSTopTabBarButton

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // configure border
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.;
        
        static const CGFloat kTitleLabelHeight = 30.;
        jsTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                                kTabBarHeight - kTitleLabelHeight,
                                                                frame.size.width,
                                                                kTitleLabelHeight)];
        
        [jsTitleLabel setFont:[UIFont systemFontOfSize:11]];
        [jsTitleLabel setNumberOfLines:2];
        [jsTitleLabel setTextColor:[UIColor whiteColor]];
        [jsTitleLabel setBackgroundColor:[UIColor colorWithRed:0. green:0. blue:0. alpha:0.5]];
        [jsTitleLabel setTextAlignment:NSTextAlignmentCenter];
        
        CALayer *layer = [jsTitleLabel layer];
        CALayer *leftBorder = [CALayer layer];
        leftBorder.borderColor = [UIColor whiteColor].CGColor;
        leftBorder.borderWidth = 1.;
        leftBorder.frame = CGRectMake(0, 0, 1, layer.frame.size.height);
        [layer addSublayer:leftBorder];
        CALayer *rightBorder = [CALayer layer];
        rightBorder.borderColor = [UIColor whiteColor].CGColor;
        rightBorder.borderWidth = 1.;
        rightBorder.frame = CGRectMake(layer.frame.size.width - 1, 0, 1, layer.frame.size.height);
        [layer addSublayer:rightBorder];
        
        [self addSubview:jsTitleLabel];
        
        badgeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        badgeLabel.backgroundColor = [UIColor redColor];
        [badgeLabel setFont:[UIFont boldSystemFontOfSize:10]];
        badgeLabel.textColor = [UIColor whiteColor];
        badgeLabel.textAlignment = NSTextAlignmentCenter;
        badgeLabel.layer.cornerRadius = 5.;
        [badgeLabel setHidden:YES];
        [self addSubview:badgeLabel];
        
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    [jsTitleLabel setText:title];
}

- (void)setBadgeNumber:(NSUInteger)badgeNumber
{
    if (badgeLabel == 0) {
        [badgeLabel setHidden:YES];
    }
    else {
        [badgeLabel setHidden:NO];
        [badgeLabel setText:[NSString stringWithFormat:@"%i", badgeNumber]];
    }
}

@end