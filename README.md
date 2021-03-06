JSTopTabBarController
=========

**A new different navigation interface in your iOS application**

`JSTopTabBarController` is a new way to navigate around your iOS application. It provides a complete class that can be used very similarly to the `UITabBarController` class. It contains a toggle button that sits above any `UIViewController` or subclass of, and when tapped, the main view controller shifts downward and tab-buttons are shown. When one of those buttons is tapped, the main view shifts back up, and switches to the `UIViewControler` that corresponds to the button tapped.

You may provide as many different `UIViewControllers` as you'd like, and  `JSTopTabBarController` sizes and scales the tab-buttons proportionally. Each tab also has the option to be given a badge number.

`JSTopTabBarController` uses AutoLayout and supports both portrait and landscape.

## Usage

Drag `JSTopTabBarController.h` and `JSTopTabBarController.m` into your project and add the following code.

In the `AppDelegate.m`, under `application:DidFinishLaunching:withOptions`, modify your window initialization code to the following.
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

The `JSTopTabBarController` is instantiated with all of the view controllers in the `init` method, and then the titles of the buttons are set. Then, the badged tab index is set, and lastly a badge number for that button is set.

## Demo

Build and run the `JSTopTabBar` project in Xcode to see a full demo of `JSTopTabBar`.

## Requirments

`JSTopTabBar` requires the `QuartzCore` framework.

## Screenshot

This is a screenshot from a more complete use of `JSTopTabBarController`.

![screenshot1](/screenshot1.png)

## Credits

Credits to the [NounProject](http://thenounproject.com), and all designers who created the icons used in this demo:

- Mike Rowe
- Rediffusion
- Christopher Holm-Hansen
- Edward Boatman

## License

Usage is provided under the [MIT License](http://opensource.org/licenses/mit-license.php). See LICENSE for the full details.

