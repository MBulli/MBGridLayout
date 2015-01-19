//
//  MenuViewController.m
//  MBGridLayout-Demo
//
//  Created by Markus Bullmann on 18/01/15.
//  Copyright (c) 2015 mbulli. All rights reserved.
//

#import "MenuViewController.h"

#import "ViewController.h"

@interface MenuViewController ()
@property(nonatomic, strong) NSArray *entries;
@property(nonatomic, strong) NSIndexPath *selectedCell;
@end

@implementation MenuViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.entries = @[ @"Fixed Column", @"2x2 Grid" ];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.entries.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.entries objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCell = indexPath;
    
    [self performSegueWithIdentifier:@"segGridDemoViewController" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segGridDemoViewController"]) {
        [segue.destinationViewController setTitle:[self.entries objectAtIndex:self.selectedCell.row]];
        [segue.destinationViewController setSelectedID:@(self.selectedCell.row)];
    }
}


@end
