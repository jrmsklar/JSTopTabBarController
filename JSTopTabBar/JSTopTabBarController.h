//
//  JSTopTabBarController.h
//  JSTopTabBar
//
//  Created by Josh Sklar on 5/14/13.
//  Copyright (c) 2013 Josh Sklar. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 JSTopTabBarController is a generic controller class that manages other view controllers. It can be used
 similarly to a UITabBarController, and acts similarly.
 */

@protocol JSTopTabBarControllerDelegate;

// JSTopTabBarController

@interface JSTopTabBarController : UIViewController

/*
 The designated initializer. Called with an array of the view controllers to manage and hold.
 Should only be called once in the entire application, as there should only be one JSTopTabBarController.
 */
- (id)initWithViewControllers:(NSArray*)viewControllers;

/* 
 Optional. If not called, numbers from 0 - viewControllers.count will be used.
 Otherwise, called with the titles of the view controllers, in order with
 respect to the viewControllers used in init.
 
 Throws exception if the size of titles is not the same as the number of the view controllers
 used in init.
 */
- (void)setTitles:(NSArray*)titles;

/*
 Optional. If not called, there will be no images, and a default gray-white gradient.
 Otherwise, called with the names of the image, as found in the main bundle,
 in order with respect to the viewControllers used in init.
 
 Throws exception if the size of titles is not the same as the number of viewControllers 
 */
- (void)setImages:(NSArray*)imageNames;

/*
 Optional. If not called, active controller defaults to the 
 first view controller passed to init.
 Otherwise, changes the active view controller held by the JSTopTabBarController object
 
 Throw exception if viewController is not in the view controllers used in init.
 */
- (void)setActiveViewController:(UIViewController*)viewController;

/*
 Optional. Sets the badge number on the viewController's respective JSTopTabBarButton.
 */
- (void)setBadgeNumber:(UIViewController*)viewController badgeNumber:(NSUInteger)badgeNum;

/* The index of the current displayed view controller. */
@property(nonatomic) NSUInteger selectedIndex;

/* The menu button background image may be changed using this property. */
@property (strong, nonatomic) UIButton *toggleTopTabBar;

@property(nonatomic,assign) id<JSTopTabBarControllerDelegate> delegate;

@end

// Delegate protocol

@protocol JSTopTabBarControllerDelegate <NSObject>

@optional
- (void)topTabBar:(JSTopTabBarController*)topTabBarController didSelectViewController:(UIViewController*)viewController;

@end

// Convenient UIViewController category

/* 
 Category on UIViewController to provide access to the topTabBar in the
 contained the view controllers used in init.
 */
@interface UIViewController (JSTopTabBarItem)

@property(nonatomic,retain) JSTopTabBarController *topTabBar;

@end

// JSTopTabBarBUtton

/* 
 Subclass of UIButton that encompasses everything that a JSTopTabBarButton needs, 
 including title label and badge number.
 */

@interface JSTopTabBarButton : UIButton
{
@private
    UILabel *jsTitleLabel;
    UILabel *badgeLabel;
}

- (id)initWithFrame:(CGRect)frame;
- (void)setTitle:(NSString *)title;
- (void)setBadgeNumber:(NSUInteger)badgeNumber;

@end