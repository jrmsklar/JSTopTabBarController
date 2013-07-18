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
#import "ViewController3.h"
#import "TableViewController.h"

@implementation JSTTBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    ViewController1 *viewController1 = [[ViewController1 alloc] init];
    ViewController2 *viewController2 = [[ViewController2 alloc] init];
    ViewController3 *viewController3 = [[ViewController3 alloc]init];
    TableViewController *tableViewController = [[TableViewController alloc]init];
    
    UINavigationController *navController1 = [[UINavigationController alloc]initWithRootViewController:viewController2];
    UINavigationController *navController2 = [[UINavigationController alloc]initWithRootViewController:tableViewController];
    
    JSTopTabBarController *topTabBarController = [[JSTopTabBarController alloc]initWithViewControllers:@[viewController1, viewController3, navController1, navController2]];
    
    [topTabBarController setTitles:@[@"Normal", @"Notifications", @"Navigation Controller", @"Table + Nav ViewController"]];
    [topTabBarController setBadgedTabIndex:1];
    [topTabBarController setBadgeNumber:3];
    
    self.window.rootViewController = topTabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
