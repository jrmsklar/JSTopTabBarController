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
    UILabel *l = [[UILabel alloc]initWithFrame:self.view.frame];
    [l setTextAlignment:NSTextAlignmentCenter];
    [l setText:@"This is a normal view controller."];
    [self.view addSubview:l];
    
    UIButton *toggle = [[UIButton alloc]
                        initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    [toggle setTitle:@"Toggle JSTTBC"
            forState:UIControlStateNormal];
    [toggle setTitleColor:[UIColor blueColor]
                 forState:UIControlStateNormal];
    [toggle setBackgroundColor:[UIColor yellowColor]];
    [toggle addTarget:self
               action:@selector(didTapToggleButton:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:toggle];
}

#pragma mark - Internal methods

- (void)didTapToggleButton:(UIButton*)sender
{
    [self.topTabBar performToggleTopTabBar];
}

@end
