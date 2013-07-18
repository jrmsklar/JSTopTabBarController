//
//  ViewController3.m
//  JSTopTabBar
//
//  Created by Josh Sklar on 7/18/13.
//  Copyright (c) 2013 Josh Sklar. All rights reserved.
//

#import "ViewController3.h"

@interface ViewController3 ()

@end

@implementation ViewController3

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Notifications";
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *l = [[UILabel alloc]initWithFrame:self.view.frame];
    [l setTextAlignment:NSTextAlignmentCenter];
    [l setText:@"Display some notifications"];
    [self.view addSubview:l];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
