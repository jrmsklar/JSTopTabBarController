//
//  RegularViewController.m
//  JSTopTabBar
//
//  Created by Josh Sklar on 5/14/13.
//  Copyright (c) 2013 Josh Sklar. All rights reserved.
//

#import "ViewController1.h"
#import "JSTopTabBarController.h"

@interface ViewController1 ()

- (void)didTapToggleButton:(UIButton*)sender;
- (void)didTapToggleEnableBorder:(UIButton*)sender;
- (void)didTapToggleShadow:(UIButton*)sender;

@end

@implementation ViewController1

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 50)];
    [l setTextAlignment:NSTextAlignmentCenter];
    [l setText:@"This is an empty view controller."];
    [self.view addSubview:l];
    
    static const CGFloat btnHeight = 50;
    
    // TODO: Move all these to a xib file.
    
    UIButton *toggle = [[UIButton alloc]
                        initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, btnHeight)];
    [toggle setTitle:@"Toggle JSTTBC"
            forState:UIControlStateNormal];
    [toggle addTarget:self
               action:@selector(didTapToggleButton:)
     forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *toggleBorders = [[UIButton alloc]
                              initWithFrame:CGRectMake(0, 160, self.view.frame.size.width, btnHeight)];
    [toggleBorders setTitle:@"Toggle JSTTBC button borders"
                  forState:UIControlStateNormal];
    [toggleBorders addTarget:self
                     action:@selector(didTapToggleEnableBorder:)
           forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *toggleShadow = [[UIButton alloc]
                              initWithFrame:CGRectMake(0, 220, self.view.frame.size.width, btnHeight)];
    [toggleShadow setTitle:@"Toggle JSTTBC button shadow"
                  forState:UIControlStateNormal];
    [toggleShadow addTarget:self
                     action:@selector(didTapToggleShadow:)
           forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *togglePanning = [[UIButton alloc]
                               initWithFrame:CGRectMake(0, 280, CGRectGetWidth(self.view.frame), btnHeight)];
    [togglePanning setTitle:@"Toggle JSTTBC arrow button panning"
                   forState:UIControlStateNormal];
    [togglePanning addTarget:self
                      action:@selector(didTapTogglePanning:)
            forControlEvents:UIControlEventTouchUpInside];
    
    for (UIButton *b in @[toggle, toggleBorders, toggleShadow, togglePanning]) {
        [b setTitleColor:[UIColor blueColor]
                     forState:UIControlStateNormal];
        [b setTitleColor:[UIColor grayColor]
                forState:UIControlStateHighlighted];
        [b setBackgroundColor:[UIColor yellowColor]];
        [self.view addSubview:b];
    }
}

#pragma mark - Internal methods

- (void)didTapToggleButton:(UIButton*)sender
{
    [self.topTabBar performToggleTopTabBar];
}

- (void)didTapToggleEnableBorder:(UIButton*)sender
{
    static BOOL toggle = NO;
    [self.topTabBar enableBordersOnTopTabBarButtons:toggle];
    toggle = !toggle;
}

- (void)didTapToggleShadow:(UIButton*)sender
{
    static BOOL toggleShadow = NO;
    [self.topTabBar enableShadowOnTopTabBarButton:toggleShadow];
    toggleShadow = !toggleShadow;
}

- (void)didTapTogglePanning:(UIButton*)sender
{
    static BOOL togglePanning = YES;
    [self.topTabBar enablePanningOfToggleTopTabBarButton:togglePanning];
    togglePanning = !togglePanning;
}

@end
