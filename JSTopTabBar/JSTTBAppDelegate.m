//
//  JSTTBAppDelegate.m
//  JSTopTabBar
//
//  Created by Josh Sklar on 5/14/13.
//  Copyright (c) 2013 Josh Sklar. All rights reserved.
//

#import "JSTTBAppDelegate.h"
#import "JSTopTabBarController.h"

#import "JSTTBNormalViewController.h"
#import "JSTTBNavigationViewController.h"
#import "JSTTBNotificationsViewController.h"
#import "JSTTBTableViewController.h"

@implementation JSTTBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    JSTTBNormalViewController *normalViewController = [[JSTTBNormalViewController alloc] init];
    JSTTBNavigationViewController *navigationViewController = [[JSTTBNavigationViewController alloc] init];
    JSTTBNotificationsViewController *notificationsViewController = [[JSTTBNotificationsViewController alloc]init];
    JSTTBTableViewController *tableViewController = [[JSTTBTableViewController alloc]init];
    
    UINavigationController *navController1 = [[UINavigationController alloc]initWithRootViewController:navigationViewController];
    UINavigationController *navController2 = [[UINavigationController alloc]initWithRootViewController:tableViewController];
    
    JSTopTabBarController *topTabBarController = [[JSTopTabBarController alloc]
                                                  initWithViewControllers:@[normalViewController, notificationsViewController, navController1, navController2]];
    
    [topTabBarController setButtonImages:@[[UIImage imageNamed:@"home"],
                                          [UIImage imageNamed:@"notifications"],
                                          [UIImage imageNamed:@"navigation2"],
                                           [UIImage imageNamed:@"navigation1"]]];
    
    [topTabBarController setButtonTitles:@[@"Normal", @"Notifications", @"Navigation Controller", @"Table + Nav ViewController"]];
    
    [topTabBarController setBadgedTabIndex:1];
    [topTabBarController setBadgeNumber:3];
    
    // can also do [topTabBarController setActiveViewControllerWithIndex:3]
    
    self.window.rootViewController = topTabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
