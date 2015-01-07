//
//  JSTTBTableViewController.m
//  JSTopTabBar
//
//  Created by Josh Sklar on 1/6/15.
//  Copyright (c) 2015 Josh Sklar. All rights reserved.
//

#import "JSTTBTableViewController.h"
#import "ViewController2.h"

@interface JSTTBTableViewController ()

@end

@implementation JSTTBTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Table View + Nav";
}

#pragma mark - Table view data source#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    [cell.textLabel setText:@"Tap Me"];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ViewController2 *vc2 = [[ViewController2 alloc]init];
    [self.navigationController pushViewController:vc2 animated:YES];
}

@end
