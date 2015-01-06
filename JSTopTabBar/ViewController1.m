//
//  ViewController1.m
//  JSTopTabBar
//
//  Created by Josh Sklar on 1/6/15.
//  Copyright (c) 2015 Josh Sklar. All rights reserved.
//

#import "ViewController1.h"
#import "JSTopTabBarController.h"

@interface ViewController1 ()

@end

@implementation ViewController1

#pragma mark - Internal methods

- (IBAction)didTapToggleButton:(UIButton*)sender
{
    [self.topTabBar performToggleTopTabBar];
}

- (IBAction)didTapToggleEnableBorder:(UIButton*)sender
{
    static BOOL toggle = NO;
    [self.topTabBar enableBordersOnTopTabBarButtons:toggle];
    toggle = !toggle;
}

- (IBAction)didTapToggleShadow:(UIButton*)sender
{
    static BOOL toggleShadow = NO;
    [self.topTabBar enableShadowOnTopTabBarButton:toggleShadow];
    toggleShadow = !toggleShadow;
}

- (IBAction)didTapTogglePanning:(UIButton*)sender
{
    static BOOL togglePanning = YES;
    [self.topTabBar enablePanningOfToggleTopTabBarButton:togglePanning];
    togglePanning = !togglePanning;
}

@end
