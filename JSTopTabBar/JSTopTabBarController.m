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
static const CGFloat kTitleLabelHeight = 30.;

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


@property (strong, nonatomic) NSMutableArray *topTabBarButtons, *topTabBarLabels;

@property(nonatomic,copy) NSArray *viewControllers;

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
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor grayColor] CGColor], nil];
        [self.view.layer insertSublayer:gradient atIndex:0];
    
        self.viewControllers = viewControllers;
        
        self.mainViewController = [self.viewControllers objectAtIndex:0];
        
        NSInteger numVCs = self.viewControllers.count;
        
        NSInteger xPos = 0;
        NSInteger btnWidth = self.view.frame.size.width / numVCs;

        NSInteger i = 0;
        
        self.topTabBarButtons = [[NSMutableArray alloc]initWithCapacity:viewControllers.count];
        self.topTabBarLabels = [[NSMutableArray alloc]initWithCapacity:viewControllers.count];
        
        for (UIViewController *vc in self.viewControllers) {
            [vc setTopTabBar:self];
            vc.view.frame = self.view.bounds;

            UIButton *b = [[UIButton alloc]initWithFrame:CGRectMake(xPos, 0, btnWidth, kTabBarHeight)];
            
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
        
        self.toggleTopTabBar = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 36, 52)];
        self.toggleTopTabBar.layer.shadowColor = [UIColor blackColor].CGColor;
        self.toggleTopTabBar.layer.shadowRadius = 10.;
        self.toggleTopTabBar.layer.shadowOpacity = 0.5;
        [self.toggleTopTabBar addTarget:self action:@selector(didTapToggleTopTabBar:) forControlEvents:UIControlEventTouchUpInside];
        [self.toggleTopTabBar setBackgroundImage:[UIImage imageNamed:@"menu_button_image"] forState:UIControlStateNormal];
        [self.view addSubview:self.toggleTopTabBar];
        [self.view bringSubviewToFront:self.toggleTopTabBar];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPanToggleTopBarButton:)];
        [self.toggleTopTabBar addGestureRecognizer:pan];
        
        topTabBarPosition = JSTTBTopTabBarNotExposed;
    }
    return self;
}

- (void)setTitles:(NSArray *)titles
{
    NSAssert(titles.count == self.topTabBarButtons.count, @"Number of titles was not equal to the number of top tab bar buttons");
    
    for (UIButton *b in self.topTabBarButtons) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(b.frame.origin.x,
                                                                      kTabBarHeight - kTitleLabelHeight,
                                                                      b.frame.size.width,
                                                                       kTitleLabelHeight)];
        [titleLabel setText:[titles objectAtIndex:b.tag]];
        [titleLabel setFont:[UIFont systemFontOfSize:12]];
        [titleLabel setNumberOfLines:2];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor colorWithRed:0. green:0. blue:0. alpha:0.5]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:titleLabel];
        [self.topTabBarLabels addObject:titleLabel];
    }

    [self.view addSubview:self.mainViewController.view];
    [self.view bringSubviewToFront:self.toggleTopTabBar];
}

- (void)setImages:(NSArray*)imageNames
{
    NSAssert(imageNames.count == self.topTabBarButtons.count, @"Number of titles was not equal to the number of top tab bar buttons");
    
    for (UIButton *b in self.topTabBarButtons) {
        [b setBackgroundImage:[UIImage imageNamed:[imageNames objectAtIndex:b.tag]] forState:UIControlStateNormal];
    }
}

- (void)setTitle:(NSString*)title;
{
    
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
    if (recognizer.state == UIGestureRecognizerStateChanged ||
        recognizer.state == UIGestureRecognizerStateEnded) {
        
        UIView *draggedButton = recognizer.view;
        CGPoint translation = [recognizer translationInView:self.view];
        
        CGRect newButtonFrame = draggedButton.frame;
        newButtonFrame.origin.x += translation.x;
        newButtonFrame.origin.y += translation.y;
        if (newButtonFrame.origin.x <= 0 || newButtonFrame.origin.y <= self.mainViewController.view.frame.origin.y)
            return;
        
        if (newButtonFrame.origin.x + newButtonFrame.size.width >= [UIScreen mainScreen].bounds.size.width ||
            newButtonFrame.origin.y + newButtonFrame.size.height >= [UIScreen mainScreen].bounds.size.height)
            return;
        
        draggedButton.frame = newButtonFrame;
        
        [recognizer setTranslation:CGPointZero inView:self.view];
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
