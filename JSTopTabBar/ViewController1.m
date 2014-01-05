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

@end

@implementation ViewController1

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    [l setTextAlignment:NSTextAlignmentCenter];
    [l setText:@"This is an empty view controller."];
    [self.view addSubview:l];
    
    UIButton *toggle = [[UIButton alloc]
                        initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    [toggle setTitle:@"Toggle JSTTBC"
            forState:UIControlStateNormal];
    [toggle addTarget:self
               action:@selector(didTapToggleButton:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:toggle];
    
    UIButton *enableBorder = [[UIButton alloc]
                              initWithFrame:CGRectMake(0, 170, self.view.frame.size.width, 50)];
    [enableBorder setTitle:@"Toggle JSTTBC button border"
                  forState:UIControlStateNormal];
    [enableBorder addTarget:self
                     action:@selector(didTapToggleEnableBorder:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:enableBorder];
    
    for (UIButton *b in @[toggle, enableBorder]) {
        [b setTitleColor:[UIColor blueColor]
                     forState:UIControlStateNormal];
        [b setBackgroundColor:[UIColor yellowColor]];
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

@end
