//
//  JSTopTabBarController.h
//  JSTopTabBar
//
//  Created by Josh Sklar on 5/14/13.
//  Copyright (c) 2013 Josh Sklar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JSTopTabBarControllerDelegate;

/**
 @class JSTopTabBarController
 
 @brief JSTopTabBarController is a generic controller class
 that manages other view controllers. It can be used
 similarly to a UITabBarController, and acts similarly.
 */

@interface JSTopTabBarController : UIViewController

/**
 The designated initializer. Called with an array of the view controllers to manage and hold.
 Should only be called once in the entire application, as there should only be one JSTopTabBarController.
 */
- (id)initWithViewControllers:(NSArray*)viewControllers;

/**
 Optional. Programatically toggles the top tab bar.
 */
- (void)performToggleTopTabBar;

/**
 Optional. If not called, numbers from 0 - viewControllers.count will be used.
 Otherwise, called with the titles of the view controllers, in order with
 respect to the viewControllers used in init.
 
 Throws exception if the size of titles is not the same as the number of the view controllers
 used in init.
 */
- (void)setButtonTitles:(NSArray*)titles;

/**
 Optional. If not called, there will be no images.
 
 Sets the images of the tab bar buttons.
 
 @images - NSArray of UIImages, ordered with respect to the
 viewControllers used in init.
 
 Throws exception if the size of @c images is not the same as the number of viewControllers
 */
- (void)setButtonImages:(NSArray *)images;

/**
 Optional. If not called, the background will be gray.
 Otherwise, called with the name of the image, as found in the main bundle,
 and sets the background to the 'backgroundImageName'
 */
- (void)setBackgroundImage:(NSString*)backgroundImageName;

/**
 Optional. If not called, active controller defaults to the
 first view controller passed to init.
 Otherwise, changes the active view controller held by the JSTopTabBarController object
 
 Throw exception if viewController is not in the view controllers used in init.
 */
- (void)setActiveViewController:(UIViewController*)viewController;

/**
 Optional. Same specifications as above, but uses integer indexing.
 */
- (void)setActiveViewControllerWithIndex:(NSUInteger)index;

/**
 Optional. Sets index's view controller (in order with respect to the view controllers
 passed to init) to the badged tab, so that when setBadgeNumber is called it knows
 which tab to used.
 
 Throw exception if index >= the number of view controllers used in init.
 */
- (void)setBadgedTabIndex:(NSUInteger)index;

/**
 Optional. Sets the badge number on the badged tab set by setBadgedTabIndex.
 
 Throw exception if setBadgedTabIndex: was never called.
 */
- (void)setBadgeNumber:(NSUInteger)badgeNum;

/**
 Optional. If not called, default 'arrow-toptabbar' is used.
 Otherwise, sets the arrow image to the specified imageName, as
 found in the main bundle
 */
- (void)setToggleTabBarButtonImage:(NSString*)imageName;

/**
 Optional. If not called, panning will be enabled.
 Determines whether or not the toggle tab bar button is pannable or not
 */
- (void)enablePanningOfToggleTopTabBarButton:(BOOL)panningEnabled;

/**
 Optional. If not called, white borders will be present on top tab bar butons.
 Determines whether there are borders around the top tab bar buttons.
 */
- (void)enableBordersOnTopTabBarButtons:(BOOL)enabled;

/**
 Optional. If not called, there will be no shadow on the top tab bar button.
 Otherwise, sets if the shadow is there or not.
 */
- (void)enableShadowOnTopTabBarButton:(BOOL)enabled;

- (void)deactiveTopTabBar;
- (void)activateTopTabBar;

/**
 The index of the current displayed view controller. 
 */
@property(nonatomic) NSUInteger selectedIndex;

/** 
 The menu button background image may be changed using this property.
 */
@property (strong, nonatomic) UIButton *toggleTopTabBar;

@property(nonatomic,assign) id<JSTopTabBarControllerDelegate> delegate;

@end

// Delegate protocol

@protocol JSTopTabBarControllerDelegate <NSObject>

@optional
- (void)topTabBar:(JSTopTabBarController*)topTabBarController didSelectViewController:(UIViewController*)viewController;

@end

/**
 @category UIViewController+JSTopTabBarItem
 
 @brief Category on UIViewController to provide access to
 the topTabBar in the contained the view controllers used in init.
 */
@interface UIViewController (JSTopTabBarItem)

@property(nonatomic,retain) JSTopTabBarController *topTabBar;

@end

/**
 @class JSTopTabBarButton
 
 @brief Subclass of UIButton that encompasses everything 
 that a JSTopTabBarButton needs, including title label and badge number.
 */

// TODO: remove the insance variables
@interface JSTopTabBarButton : UIButton
{
@private
    UILabel *jsTitleLabel;
    UILabel *badgeLabel;
    UIImageView *activeDotImageView;
    UIImageView *backgroundImageView;
}

- (id)initWithFrame:(CGRect)frame;
- (void)setTitle:(NSString *)title;
- (void)setImage:(UIImage *)image;
- (void)setBadgeNumber:(NSUInteger)badgeNumber;
- (void)setActive:(BOOL)active;
- (void)enableBorder:(BOOL)enabled;

@end