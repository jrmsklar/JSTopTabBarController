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

static const CGFloat kTabBarHeight = 90.;

static const CGFloat kToggleTopTabBarButtonBuffer = 20.;

static const UIViewAnimationOptions kAnimationOptions = UIViewAnimationOptionCurveEaseInOut;

typedef enum {
    JSTTBTopTabBarExposed,
    JSTTBTopTabBarNotExposed
} JSTTBTopTabBarPosition;

typedef enum {
    JSTTBMoveDirectionUp,
    JSTTBMoveDirectionDown
} JSTTBMoveDirection;

@interface JSTopTabBarController ()

/* private methods */
- (void)constrainViewToEntireSuperview:(UIView *)view;
- (void)didTapToggleTopTabBar:(id)sender;
- (void)didTapTopTabBarButton:(id)sender;

- (void)didTapOverlay:(id)sender;

@property (nonatomic) JSTTBTopTabBarPosition topTabBarPosition;

/**
 Array of all of the buttons contained in the JSTopTabBarController.
 */
@property (strong, nonatomic) NSMutableArray *topTabBarButtons;

@property(nonatomic,copy) NSArray *viewControllers;

/**
 The active view controller.
 */
@property (strong, nonatomic) UIViewController *mainViewController;

@property (strong, nonatomic) UIView *overlay;

@property (strong, nonatomic) UIImageView *backgroundImageView;

@property NSUInteger indexOfBadgedTab;

/**
 Width constraint for the first top tab bar button. All of the other buttons
 have equal width.
 */
@property (strong, nonatomic) NSLayoutConstraint *topTabBarButtonWidthConstraint;

/**
 Top constraint for the first top tab bar button. All of the other buttons
 are aligned to the top of the first one.
 */
@property (strong, nonatomic) NSLayoutConstraint *topTabBarButtonTopConstraint;

/**
 Top constraint for the toggle top tab bar button. Gets adjusted when the top tab
 bar is toggled.
 */
@property (strong, nonatomic) NSLayoutConstraint *toggleTopTabBarButtonTopConstraint;

@end

/**
 @category UIViewController+JSTopTabBarController
 
 @brief Category on UIViewController to provide convenience methods to
 add/remove child view controllers, move views, perform animations, and fade views.
 */

@interface UIViewController(JSTopTabBarController)

/**
 Convenience method to add a new child view controller. Performs all of the UIViewController
 containment logic required.
 */
- (void)JSTTB_addChildViewController:(UIViewController *)childViewController;

/**
 Convenience method to remove a child view controller. Performs all of the UIViewController
 containment logic required.
 */
- (void)JSTTB_removeFromParentViewController;

- (void)JSTTB_move:(UIView*)view
         direction:(JSTTBMoveDirection)direction
                by:(NSInteger)amount
      withDuration:(NSTimeInterval)duration
   completionBlock:(void (^)(BOOL finished))block;

- (void)JSTTB_partialFade:(UIView*)view
               finalAlpha:(CGFloat)alpha
             withDuration:(NSTimeInterval)duration
          completionBlock:(void (^)(BOOL finished))block;

- (void)JSTTB_adjustConstraint:(NSLayoutConstraint *)constraint
                      constant:(CGFloat)constant
                      duration:(NSTimeInterval)duration
               completionBlock:(void (^)(BOOL finished))block;

@end

@implementation JSTopTabBarController

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor grayColor];
        
        self.backgroundImageView = [[UIImageView alloc]init];
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.backgroundImageView setImage:nil];
        [self.view addSubview:self.backgroundImageView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_backgroundImageView);
        NSDictionary *metrics = @{@"backgroundImageViewHeight": @(kTabBarHeight)};
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImageView(backgroundImageViewHeight)]"
                                                                         options:kNilOptions
                                                                         metrics:metrics
                                                                            views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImageView]|"
                                                                         options:kNilOptions
                                                                         metrics:nil
                                                                            views:views]];
        
        self.viewControllers = viewControllers;
        
        self.mainViewController = [self.viewControllers objectAtIndex:0];
        
        NSInteger xPosition = 0;
        CGFloat buttonWidth = CGRectGetWidth(self.view.frame) / self.viewControllers.count;
        
        NSInteger buttonTag = 0;
        
        self.topTabBarButtons = [[NSMutableArray alloc]initWithCapacity:viewControllers.count];
        
        for (UIViewController *vc in self.viewControllers) {
            vc.topTabBar = self;
            vc.view.frame = self.view.bounds;
            
            JSTopTabBarButton *button = [[JSTopTabBarButton alloc]init];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            [button setTitle:[NSString stringWithFormat:@"%li", (long)buttonTag]];
            button.tag = buttonTag;
            [button addTarget:self action:@selector(didTapTopTabBarButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
            
            [self.topTabBarButtons addObject:button];
            
            xPosition += buttonWidth;
            buttonTag++;
        }
        
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        
        // Constrain the first button
        if (self.topTabBarButtons.count > 0) {
            JSTopTabBarButton *firstButton = [self.topTabBarButtons firstObject];
            NSString *firstButtonKey = @"button0";
            NSMutableDictionary *views = [@{firstButtonKey: firstButton} mutableCopy];
            
            // Constrain it vertically
            self.topTabBarButtonTopConstraint = [NSLayoutConstraint constraintWithItem:firstButton
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.view
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.
                                                                              constant:statusBarHeight];
            [self.view addConstraint:self.topTabBarButtonTopConstraint];
            
            // Constrain it horizontally
            NSString *horizontalVisualFormatString =
            [NSString stringWithFormat:@"H:|[%@]", firstButtonKey];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalVisualFormatString
                                                                              options:kNilOptions
                                                                              metrics:nil
                                                                                views:views]];
            
            // Constrain the height
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:firstButton
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.
                                                                   constant:kTabBarHeight]];

            self.topTabBarButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:firstButton
                                                                               attribute:NSLayoutAttributeWidth
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1.
                                                                                constant:buttonWidth];
            
            [self.view addConstraint:self.topTabBarButtonWidthConstraint];
            
            [self.view setNeedsLayout];
            
            JSTopTabBarButton *previousButton = firstButton;
            NSString *previousButtonKey = firstButtonKey;
            [views setObject:previousButton
                      forKey:previousButtonKey];
            
            // Constrain the rest of the buttons
            for (NSInteger index = 1; index < self.topTabBarButtons.count; index++) {
                JSTopTabBarButton *nextButton = [self.topTabBarButtons objectAtIndex:index];

                // Assign equal height and width of every button to the first button
                [self.view addConstraint:[NSLayoutConstraint constraintWithItem:nextButton
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:firstButton
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:1.
                                                                       constant:0.]];
                
                [self.view addConstraint:[NSLayoutConstraint constraintWithItem:nextButton
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:firstButton
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:1.
                                                                       constant:0.]];
                
                NSString *nextButtonKey = [NSString stringWithFormat:@"button%li", (long)index];
                [views setObject:nextButton
                          forKey:nextButtonKey];
                
                // Align the next button to the top of the first button, and next to the previous button
                [self.view addConstraint:[NSLayoutConstraint constraintWithItem:nextButton
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:firstButton
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.
                                                                       constant:0.]];
                horizontalVisualFormatString = [NSString stringWithFormat:@"H:[%@]-0-[%@]", previousButtonKey, nextButtonKey];
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalVisualFormatString
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                    views:views]];
                previousButton = nextButton;
                previousButtonKey = nextButtonKey;
            }
        }
        
        [self.view layoutIfNeeded];
        
        [[self.topTabBarButtons objectAtIndex:0] setActive:YES];
        
        self.selectedIndex = 0;
        
        [self JSTTB_addChildViewController:self.mainViewController];
        
        self.overlay = [[UIView alloc]init];
        self.overlay.translatesAutoresizingMaskIntoConstraints = NO;
        [self.overlay setBackgroundColor:[UIColor blackColor]];
        [self.overlay setAlpha:0.];
        UITapGestureRecognizer *tappedOverlay = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOverlay:)];
        [self.overlay addGestureRecognizer:tappedOverlay];
        [self.mainViewController.view addSubview:self.overlay];
        
        [self constrainViewToEntireSuperview:self.overlay];
        
        self.toggleTopTabBar = [UIButton buttonWithType:UIButtonTypeCustom];
        self.toggleTopTabBar.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addSubview:self.toggleTopTabBar];
        [self.view bringSubviewToFront:self.toggleTopTabBar];
        
        // Constrain it vertically
        self.toggleTopTabBarButtonTopConstraint = [NSLayoutConstraint constraintWithItem:self.toggleTopTabBar
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.view
                                                                               attribute:NSLayoutAttributeTop
                                                                              multiplier:1.
                                                                                constant:kToggleTopTabBarButtonBuffer];
        [self.view addConstraint:self.toggleTopTabBarButtonTopConstraint];
        
        // Constrain it horizontally
        NSString *toggleTopTabBarKey = @"toggleTopTabBar";
        views = [@{toggleTopTabBarKey: self.toggleTopTabBar} mutableCopy];
        
        NSString *spacingKey = @"spacing";
        NSDictionary *toggleTopTabBarMetrics = @{spacingKey: @(kToggleTopTabBarButtonBuffer)};
        
        NSString *horizontalVisualFormatString =
        [NSString stringWithFormat:@"H:[%@]-%@-|", toggleTopTabBarKey, spacingKey];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalVisualFormatString
                                                                          options:kNilOptions
                                                                          metrics:toggleTopTabBarMetrics
                                                                            views:views]];

        [self enableShadowOnTopTabBarButton:YES];
        [self.toggleTopTabBar addTarget:self action:@selector(didTapToggleTopTabBar:) forControlEvents:UIControlEventTouchUpInside];
        [self.toggleTopTabBar setBackgroundImage:[UIImage imageNamed:@"arrow-toptabbar"] forState:UIControlStateNormal];
        
        [self.view layoutIfNeeded];
        
        self.topTabBarPosition = JSTTBTopTabBarNotExposed;
        
        self.indexOfBadgedTab = -1;
    }
    return self;
}

/*
 When transitioning the view's size (eg. changing device orientation),
 udate the width and top constraints for the top tab bar buttons.
 */
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    NSInteger buttonWidth = size.width / self.viewControllers.count;
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        self.topTabBarButtonWidthConstraint.constant = buttonWidth;
        
        CGFloat height = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        self.topTabBarButtonTopConstraint.constant = height;
        
        [self.view layoutIfNeeded];
        
    } completion:NULL];
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

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    [self.backgroundImageView setImage:backgroundImage];
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
            [self constrainViewToEntireSuperview:self.overlay];
            
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

- (void)setToggleTabBarButtonImage:(UIImage *)image
{
    [self.toggleTopTabBar setBackgroundImage:image forState:UIControlStateNormal];
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

- (void)constrainViewToEntireSuperview:(UIView *)view
{
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    
    UIView *superiew = view.superview;
    
    [superiew addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                    options:kNilOptions
                                                                    metrics:nil
                                                                       views:views]];
    
    [superiew addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:views]];
}

- (void)didTapToggleTopTabBar:(id)sender
{
    static CGFloat animationDuration = 0.2;
    
    CGFloat moveAmount = kTabBarHeight + self.topTabBarButtonTopConstraint.constant;
    
    switch (self.topTabBarPosition) {
        case JSTTBTopTabBarNotExposed:
            /* move the main view controller and the toggle button down */
            [self JSTTB_move:self.mainViewController.view
                   direction:JSTTBMoveDirectionDown
                          by:moveAmount
                withDuration:animationDuration
             completionBlock:NULL];
            [self JSTTB_adjustConstraint:self.toggleTopTabBarButtonTopConstraint
                                constant:(kToggleTopTabBarButtonBuffer + moveAmount)
                                duration:animationDuration
                         completionBlock:NULL];
            
            self.topTabBarPosition = JSTTBTopTabBarExposed;
            [self.mainViewController.view bringSubviewToFront:self.overlay];
            [self JSTTB_partialFade:self.overlay finalAlpha:0.7 withDuration:animationDuration completionBlock:nil];
            break;
        default:
            /* move the main view controller and the toggle button up */
            [self JSTTB_move:self.mainViewController.view direction:JSTTBMoveDirectionUp by:moveAmount withDuration:animationDuration completionBlock:nil];
            [self JSTTB_adjustConstraint:self.toggleTopTabBarButtonTopConstraint
                                constant:kToggleTopTabBarButtonBuffer
                                duration:animationDuration
                         completionBlock:NULL];
            
            self.topTabBarPosition = JSTTBTopTabBarNotExposed;
            [self JSTTB_partialFade:self.overlay finalAlpha:0. withDuration:animationDuration completionBlock:nil];
            break;
    }
}

- (void)didTapTopTabBarButton:(id)sender
{
    JSTopTabBarButton *b = (JSTopTabBarButton*)sender;
    
    for (JSTopTabBarButton *b in self.topTabBarButtons) {
        [b setActive:NO];
    }
    
    [b setActive:YES];
    
    self.selectedIndex = b.tag;
    
    [self.mainViewController JSTTB_removeFromParentViewController];
    
    UIViewController *nextViewController = [self.viewControllers objectAtIndex:b.tag];
    nextViewController.view.frame = self.mainViewController.view.frame;
    
    self.mainViewController = nextViewController;
    
    [self.overlay removeFromSuperview];
    [self.mainViewController.view addSubview:self.overlay];
    [self constrainViewToEntireSuperview:self.overlay];
    
    [self JSTTB_addChildViewController:self.mainViewController];
    
    [self.view bringSubviewToFront:self.toggleTopTabBar];
    
    [self didTapToggleTopTabBar:nil];
}

- (void)didTapOverlay:(id)sender
{
    [self didTapToggleTopTabBar:nil];
}

@end

@implementation UIViewController (JSTopTabBarItem)

static const char* topTabBarKey = "TopTabBarKey";

- (JSTopTabBarController*)topTabBar_core
{
    return objc_getAssociatedObject(self, topTabBarKey);
}

- (JSTopTabBarController*)topTabBar
{
    id result = [self topTabBar_core];
    return result;
}

- (void)setTopTabBar:(JSTopTabBarController *)topTabBar
{
    objc_setAssociatedObject(self, topTabBarKey, topTabBar, OBJC_ASSOCIATION_ASSIGN);
}

@end

@interface JSTopTabBarButton ()

@property (strong, nonatomic) UILabel *jsTitleLabel;
@property (strong, nonatomic) UILabel *badgeLabel;
@property (strong, nonatomic) UIImageView *backgroundImageView;

@end

@implementation JSTopTabBarButton

- (id)init
{
    if (self = [super init]) {
        // Configure border
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        [self enableBorder:YES];
    
        self.jsTitleLabel = [[UILabel alloc]init];
        self.jsTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.jsTitleLabel];
        
        self.badgeLabel = [[UILabel alloc]init];
        self.badgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.badgeLabel];
        
        self.backgroundImageView = [[UIImageView alloc]init];
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.backgroundImageView];
        [self sendSubviewToBack:self.backgroundImageView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_jsTitleLabel, _badgeLabel, _backgroundImageView);
        
        // Add constraints for the titleLabel
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_jsTitleLabel]|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_jsTitleLabel]|"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:views]];
        
        // Add constraints for the backgroundImageView
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundImageView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.
                                                          constant:0.]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImageView]-[_jsTitleLabel]"
                                                                     options:kNilOptions
                                                                     metrics:nil
                                                                       views:views]];
        [self.jsTitleLabel setFont:[UIFont systemFontOfSize:11]];
        [self.jsTitleLabel setNumberOfLines:0];
        [self.jsTitleLabel setTextColor:[UIColor whiteColor]];
        [self.jsTitleLabel setBackgroundColor:[UIColor clearColor]];
        [self.jsTitleLabel setTextAlignment:NSTextAlignmentCenter];
        
        NSDictionary *metrics = @{@"badgeLabelSize": @20};
        
        // Add constraints for the badgeLabel
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_badgeLabel(badgeLabelSize)]"
                                                                    options:kNilOptions
                                                                    metrics:metrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_badgeLabel(badgeLabelSize)]"
                                                                    options:kNilOptions
                                                                    metrics:metrics
                                                                       views:views]];
        
        
        self.badgeLabel.backgroundColor = [UIColor redColor];
        [self.badgeLabel setFont:[UIFont boldSystemFontOfSize:11]];
        self.badgeLabel.textColor = [UIColor whiteColor];
        self.badgeLabel.textAlignment = NSTextAlignmentCenter;
        self.badgeLabel.layer.cornerRadius = 5.;
        [self.badgeLabel setHidden:YES];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    [self.jsTitleLabel setText:title];
}

- (void)setImage:(UIImage *)image
{
    [self.backgroundImageView setImage:image];
}

- (void)setBadgeNumber:(NSUInteger)badgeNumber
{
    if (badgeNumber == 0) {
        [self.badgeLabel setHidden:YES];
    }
    else {
        [self.badgeLabel setHidden:NO];
        [self.badgeLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)badgeNumber]];
    }
}

- (void)setActive:(BOOL)active
{
    if (!active) {
        [self.jsTitleLabel setTextColor:[UIColor whiteColor]];
        [self.jsTitleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:11]];
    }
    else {
        [self.jsTitleLabel setTextColor:[UIColor blueColor]];
        [self.jsTitleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
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

@implementation UIViewController(JSTopTabBarController)

- (void)JSTTB_addChildViewController:(UIViewController *)childViewController
{
    [self addChildViewController:childViewController];
    [self.view addSubview:childViewController.view];
    [childViewController didMoveToParentViewController:self];
}

- (void)JSTTB_removeFromParentViewController
{
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)JSTTB_move:(UIView*)view
         direction:(JSTTBMoveDirection)direction
                by:(NSInteger)amount
      withDuration:(NSTimeInterval)duration
   completionBlock:(void (^)(BOOL finished))block
{
    [UIView animateWithDuration:duration
                          delay:0
                        options:kAnimationOptions
                     animations:^{
                         switch (direction) {
                             case JSTTBMoveDirectionUp:
                                 view.center = CGPointMake(view.center.x, view.center.y - amount);
                                 /* rotate toggleTopTabBar 180 degrees */
                                 self.topTabBar.toggleTopTabBar.transform = CGAffineTransformMakeRotation(M_PI*2);
                                 break;
                             case JSTTBMoveDirectionDown:
                                 self.topTabBar.toggleTopTabBar.transform = CGAffineTransformMakeRotation(M_PI);
                                 /* rotate toggleTopTabBar 180 degrees */
                                 view.center = CGPointMake(view.center.x, view.center.y + amount);
                                 break;
                             default:
                                 break;
                         }
                     }
                     completion:block];
}

- (void)JSTTB_partialFade:(UIView*)view
               finalAlpha:(CGFloat)alpha
             withDuration:(NSTimeInterval)duration
          completionBlock:(void (^)(BOOL finished))block
{
    [UIView animateWithDuration:duration
                          delay:0
                        options:kAnimationOptions
                     animations:^{
                         view.alpha = alpha;
                     }
                     completion:block];
}

- (void)JSTTB_adjustConstraint:(NSLayoutConstraint *)constraint
                      constant:(CGFloat)constant
                      duration:(NSTimeInterval)duration
               completionBlock:(void (^)(BOOL))block
{
    [UIView animateWithDuration:duration
                          delay:0
                        options:kAnimationOptions
                     animations:^{
                         constraint.constant = constant;
                         [self.view layoutIfNeeded];
                     } completion:block];
}

@end
