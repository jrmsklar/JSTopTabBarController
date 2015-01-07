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

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

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

@property (strong, nonatomic) UIImageView *backgroundImageView;

@property NSUInteger indexOfBadgedTab;

@end

@implementation JSTopTabBarController

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor grayColor];
        
        self.backgroundImageView = [[UIImageView alloc]
                                    initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kTabBarHeight)];
        [self.backgroundImageView setImage:nil];
        [self.view addSubview:self.backgroundImageView];
        
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
            
            JSTopTabBarButton *button = [[JSTopTabBarButton alloc]init];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            [button setTitle:[NSString stringWithFormat:@"%li", (long)i]];
            button.tag = i;
            [button addTarget:self action:@selector(didTapTopTabBarButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
            
            [self.topTabBarButtons addObject:button];
            
            xPos += btnWidth;
            i++;
        }
        
        [[self.topTabBarButtons objectAtIndex:0] setActive:YES];
        
        self.selectedIndex = 0;
        
        [self.view addSubview:self.mainViewController.view];
        
        // TODO: Use AutoLayout. Make this constrainted to the self.view
        self.overlay = [[UIView alloc]initWithFrame:self.view.bounds];
        [self.overlay setBackgroundColor:[UIColor blackColor]];
        [self.overlay setAlpha:0.];
        UITapGestureRecognizer *tappedOverlay = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOverlay:)];
        [self.overlay addGestureRecognizer:tappedOverlay];
        
        [self.mainViewController.view addSubview:self.overlay];
        
        CGRect frame;
        
        // TODO: Don't use raw constants
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            frame = CGRectMake(self.view.bounds.size.width - 20 - 10, 30, 20, 20);
        else
            frame = CGRectMake(self.view.bounds.size.width - 20 - 10, 12, 20, 20);
        
        self.toggleTopTabBar = [[UIButton alloc]initWithFrame:frame];
        self.toggleTopTabBar.layer.shadowColor = [UIColor blackColor].CGColor;
        self.toggleTopTabBar.layer.shadowRadius = 10.;
        self.toggleTopTabBar.layer.shadowOpacity = 0.5;
        [self.toggleTopTabBar addTarget:self action:@selector(didTapToggleTopTabBar:) forControlEvents:UIControlEventTouchUpInside];
        [self.toggleTopTabBar setBackgroundImage:[UIImage imageNamed:@"arrow-toptabbar"] forState:UIControlStateNormal];
        [self.view addSubview:self.toggleTopTabBar];
        [self.view bringSubviewToFront:self.toggleTopTabBar];
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPanToggleTopBarButton:)];
        
        [self.toggleTopTabBar addGestureRecognizer:self.panGestureRecognizer];
        
        topTabBarPosition = JSTTBTopTabBarNotExposed;
        
        self.indexOfBadgedTab = -1;
    }
    return self;
}

- (void)performToggleTopTabBar
{
    [self didTapToggleTopTabBar:nil];
}

- (void)setButtonTitles:(NSArray *)titles
{
    NSAssert(titles.count == self.topTabBarButtons.count, @"Number of titles was not equal to the number of top tab bar buttons");
    
    for (JSTopTabBarButton *button in self.topTabBarButtons) {
        [button setTitle:[titles objectAtIndex:button.tag]];
    }
}

- (void)setButtonImages:(NSArray *)images
{
    NSAssert(images.count == self.topTabBarButtons.count, @"Number of titles was not equal to the number of top tab bar buttons");
    
    for (JSTopTabBarButton *button in self.topTabBarButtons) {
        [button setImage:[images objectAtIndex:button.tag]];
    }
}

- (void)setBackgroundImage:(NSString*)backgroundImageName
{
    [self.backgroundImageView setImage:[UIImage imageNamed:backgroundImageName]];
}

- (void)setActiveViewController:(UIViewController*)viewController
{
    NSInteger tag = 0;
    for (UIViewController *vc in self.viewControllers) {
        if (vc == viewController) {
            [self.mainViewController.view removeFromSuperview];
            self.mainViewController = vc;
            [self.view addSubview:self.mainViewController.view];
            [self.view bringSubviewToFront:self.toggleTopTabBar];
            
            [self.overlay removeFromSuperview];
            [self.mainViewController.view addSubview:self.overlay];
            
            // update the active indicator on the butons
            for (JSTopTabBarButton *b in self.topTabBarButtons)
                if (b.tag == tag)
                    [b setActive:YES];
                else
                    [b setActive:NO];
            
            return;
        }
        tag++;
    }
    NSAssert(NO, @"View controller passed to setActiveViewController was not in self.viewControllers");
}

- (void)setActiveViewControllerWithIndex:(NSUInteger)index
{
    NSAssert(index < self.viewControllers.count, @"Index passed to setActiveViewControllerWithIndex was out of bounds of self.viewControllers.count");
    [self setActiveViewController:[self.viewControllers objectAtIndex:index]];
}

- (void)setBadgedTabIndex:(NSUInteger)index
{
    NSAssert(index < self.viewControllers.count, @"Index passed to setBadgedTabIndex was not less than self.viewcontrollers.count");
    
    self.indexOfBadgedTab = index;
}


- (void)setBadgeNumber:(NSUInteger)badgeNum
{
    NSAssert(self.indexOfBadgedTab != -1, @"indexOfBadgedTab was not yet set");
    
    JSTopTabBarButton *b = (JSTopTabBarButton*)[self.topTabBarButtons objectAtIndex:self.indexOfBadgedTab];
    [b setBadgeNumber:badgeNum];
}

- (void)setToggleTabBarButtonImage:(NSString*)imageName
{
    [self.toggleTopTabBar setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)enablePanningOfToggleTopTabBarButton:(BOOL)panningEnabled
{
    if (!panningEnabled)
        [self.toggleTopTabBar removeGestureRecognizer:self.panGestureRecognizer];
    else
        [self.toggleTopTabBar addGestureRecognizer:self.panGestureRecognizer];
}

- (void)enableBordersOnTopTabBarButtons:(BOOL)enabled
{
    for (JSTopTabBarButton *btn in self.topTabBarButtons)
        [btn enableBorder:enabled];
}

- (void)enableShadowOnTopTabBarButton:(BOOL)enabled
{
    if (enabled) {
        self.toggleTopTabBar.layer.shadowColor = [UIColor blackColor].CGColor;
        self.toggleTopTabBar.layer.shadowRadius = 10.;
        self.toggleTopTabBar.layer.shadowOpacity = 0.5;
    }
    else {
        self.toggleTopTabBar.layer.shadowRadius = 0.;
        self.toggleTopTabBar.layer.shadowOpacity = 0.;
    }
}

- (void)deactiveTopTabBar
{
    [self.toggleTopTabBar setHidden:YES];
    for (JSTopTabBarButton *b in self.topTabBarButtons) {
        [b setHidden:YES];
    }
}

- (void)activateTopTabBar
{
    [self.toggleTopTabBar setHidden:NO];
    for (JSTopTabBarButton *b in self.topTabBarButtons) {
        [b setHidden:NO];
    }
    [self.view bringSubviewToFront:self.mainViewController.view];
    [self.view bringSubviewToFront:self.toggleTopTabBar];
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
    JSTopTabBarButton *b = (JSTopTabBarButton*)sender;
    
    for (JSTopTabBarButton *b in self.topTabBarButtons)
        [b setActive:NO];
    
    [b setActive:YES];
    
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

- (id)init
{
    if (self = [super init]) {
        // configure border
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.;
    
        jsTitleLabel = [[UILabel alloc]init];
        jsTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:jsTitleLabel];
        
        badgeLabel = [[UILabel alloc]init];
        badgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:badgeLabel];
        
        backgroundImageView = [[UIImageView alloc]init];
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:backgroundImageView];
        [self sendSubviewToBack:backgroundImageView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(jsTitleLabel, badgeLabel, backgroundImageView);
        
        // Add constraints for the titleLabel
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[jsTitleLabel]|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[jsTitleLabel]|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:views]];
        
        // Add constraints for the backgroundImageView
        [self addConstraint:[NSLayoutConstraint constraintWithItem:backgroundImageView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.
                                                          constant:0.]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundImageView]-[jsTitleLabel]"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:views]];
        [jsTitleLabel setFont:[UIFont systemFontOfSize:11]];
        [jsTitleLabel setNumberOfLines:0];
        [jsTitleLabel setTextColor:[UIColor whiteColor]];
        [jsTitleLabel setBackgroundColor:[UIColor clearColor]];
        [jsTitleLabel setTextAlignment:NSTextAlignmentCenter];
        
        NSDictionary *metrics = @{@"badgeLabelSize": @20};
        
        // Add constraints for the badgeLabel
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[badgeLabel(badgeLabelSize)]"
                                                                    options:kNilOptions
                                                                    metrics:metrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[badgeLabel(badgeLabelSize)]"
                                                                    options:kNilOptions
                                                                    metrics:metrics
                                                                       views:views]];
        
        
        badgeLabel.backgroundColor = [UIColor redColor];
        [badgeLabel setFont:[UIFont boldSystemFontOfSize:11]];
        badgeLabel.textColor = [UIColor whiteColor];
        badgeLabel.textAlignment = NSTextAlignmentCenter;
        badgeLabel.layer.cornerRadius = 5.;
        [badgeLabel setHidden:YES];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    [jsTitleLabel setText:title];
}

- (void)setImage:(UIImage *)image
{
    [backgroundImageView setImage:image];
}

- (void)setBadgeNumber:(NSUInteger)badgeNumber
{
    if (badgeNumber == 0) {
        [badgeLabel setHidden:YES];
    }
    else {
        [badgeLabel setHidden:NO];
        [badgeLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)badgeNumber]];
    }
}

- (void)setActive:(BOOL)active
{
    if (!active) {
        [jsTitleLabel setTextColor:[UIColor whiteColor]];
        [jsTitleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:11]];
    }
    else {
        [jsTitleLabel setTextColor:[UIColor blueColor]];
        [jsTitleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
    }
}

- (void)enableBorder:(BOOL)enabled
{
    if (enabled)
        self.layer.borderWidth = 1.;
    else
        self.layer.borderWidth = 0.;
}

@end
