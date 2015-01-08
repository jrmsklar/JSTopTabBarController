//
//  JSTTBTableViewController.m
//  JSTopTabBar
//
//  Created by Josh Sklar on 1/6/15.
//  Copyright (c) 2015 Josh Sklar. All rights reserved.
//

#import "JSTTBTableViewController.h"
#import "JSTTBNavigationViewController.h"

@implementation JSTTBTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Table View + Nav";
}

#pragma mark - Table view data source#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell.textLabel setText:@"Tap Me"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JSTTBNavigationViewController *vc = [[JSTTBNavigationViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
