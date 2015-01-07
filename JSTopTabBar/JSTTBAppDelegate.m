//
//  JSTTBAppDelegate.m
//  JSTopTabBar
//
//  Created by Josh Sklar on 5/14/13.
//  Copyright (c) 2013 Josh Sklar. All rights reserved.
//

#import "JSTTBAppDelegate.h"
#import "JSTopTabBarController.h"

#import "ViewController1.h"
#import "ViewController2.h"
#import "JSTTBNotificationsViewController.h"
#import "JSTTBTableViewController.h"

@implementation JSTTBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    ViewController1 *viewController1 = [[ViewController1 alloc] init];
    ViewController2 *viewController2 = [[ViewController2 alloc] init];
    JSTTBNotificationsViewController *notificationsViewController = [[JSTTBNotificationsViewController alloc]init];
    JSTTBTableViewController *tableViewController = [[JSTTBTableViewController alloc]init];
    
    UINavigationController *navController1 = [[UINavigationController alloc]initWithRootViewController:viewController2];
    UINavigationController *navController2 = [[UINavigationController alloc]initWithRootViewController:tableViewController];
    
    JSTopTabBarController *topTabBarController = [[JSTopTabBarController alloc]
                                                  initWithViewControllers:@[viewController1, notificationsViewController, navController1, navController2]];
    [topTabBarController setButtonImages:@[[UIImage imageNamed:@"home"],
                                          [UIImage imageNamed:@"notifications"],
                                          [UIImage imageNamed:@"navigation2"],
                                           [UIImage imageNamed:@"navigation1"]]];
    
    [topTabBarController setButtonTitles:@[@"Normal", @"Notifications", @"Navigation Controller", @"Table + Nav ViewController"]];
    [topTabBarController setBadgedTabIndex:1];
    [topTabBarController setBadgeNumber:3];
    // can also do [topTabBarController setActiveViewControllerWithIndex:3]
    [topTabBarController enablePanningOfToggleTopTabBarButton:NO];
    
    self.window.rootViewController = topTabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
