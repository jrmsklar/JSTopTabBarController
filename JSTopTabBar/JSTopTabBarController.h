//
//  JSTopTabBarController.h
//  JSTopTabBar
//
//  Created by Josh Sklar on 5/14/13.
//  Copyright (c) 2013 Josh Sklar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JSTopTabBarControllerDelegate;

@interface JSTopTabBarController : UIViewController

- (id)initWithViewControllers:(NSArray*)viewControllers;

/* optional. If not called, the view controllers' titles will be used.
 otherwise, called with the titles of the view controllers, in order with
 respect to the viewControllers used in init.
 Throws exception if the size of titles is not the same as the number of viewControllers */
- (void)setTitles:(NSArray*)titles;

/* optional. If note called, there will be no images.
 otherwise, called with the names of the image, as found in the main bundle,
 in order with respect to the viewControllers used in init.
 Throws exception if the size of titles is not the same as the number of viewControllers */
- (void)setImages:(NSArray*)imageNames;

- (void)setTitle:(NSString*)title;

/* the index of the current displayed view controller */
@property(nonatomic) NSUInteger selectedIndex;

/* the menu button background image may be changed using this property */
@property (strong, nonatomic) UIButton *toggleTopTabBar;


@property(nonatomic,assign) id<JSTopTabBarControllerDelegate> delegate;

@end

@protocol JSTopTabBarControllerDelegate <NSObject>

@optional
- (void)topTabBar:(JSTopTabBarController*)topTabBarController didSelectViewController:(UIViewController*)viewController;

@end

// category on UIViewController to provide access to the topTabBar in the
// contained viewcontrollers, a la UINavigationController.

@interface UIViewController (JSTopTabBarItem)

@property(nonatomic,retain) JSTopTabBarController *topTabBar;

@end