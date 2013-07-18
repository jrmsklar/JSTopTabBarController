JSTopTabBarController
=========

**A new different interface to navigating around your iOS application**

`JSTopTabBarController` is a new way to navigate around your iOS application. It provides a complete class that can be used very similarly to the UITabBarController class. It contains a toggle button that sits above any `UIViewController` or subclass of, and when tapped, the main view controller shifts downward and tab-buttons are shown. When one of those buttons is tapped, the main view shifts back up, and switches to whichever view corresponds to the button tapped.

You may provide as many different view controllers as you'd like, and  `JSTopTabBarController` sizes and scales the tab-buttons proportionally. Each tab also has the option to be given a badge number, as you may simulate any type of notification with any of the tabs. 

## Usage

In the AppDelegate.m, under application:DidFinishLaunching:withOptions, modify your window initialization code to the following.
After instantiating all of the main view controllers, use the following code:
``` objective-c
JSTopTabBarController *topTabBarController = [[JSTopTabBarController alloc]initWithViewControllers:@[viewController1, viewController2, navController1, viewController3]];

[topTabBarController setTitles:@[@"Normal", @"Notifications", @"Nav Controller", @"Regular ViewController"]];
[topTabBarController setBadgedTabIndex:1];
[topTabBarController setBadgeNumber:3];

self.window.rootViewController = topTabBarController;
[self.window makeKeyAndVisible];
return YES;
```
We instantiate an instance of the `JSTopTabBarController` with all of the view controllers in the `init` method, and then set the titles of the buttons, the badged tab index, or thet index to be badged, and we set a badge number.

## Demo

Build and run the `JSTopTabBar` project to see `JSTopTabBar` in action.

## Requirments

`JSTopTabBar` requires the `QuartzCore` framework.

## Screenshots

![screenshot1](/screenshot1.png)

