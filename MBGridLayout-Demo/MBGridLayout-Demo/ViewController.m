//
//  ViewController.m
//  MBGridLayout-Demo
//
//  Created by Markus Bullmann on 18/01/15.
//  Copyright (c) 2015 mbulli. All rights reserved.
//

#import "ViewController.h"

@import MBGridLayout;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MBGridView *gridView;

@property(nonatomic, assign) NSInteger viewNumber;
@property(nonatomic, strong) UIView *view1;
@property(nonatomic, strong) UIView *view2;
@property(nonatomic, strong) UIView *view3;
@property(nonatomic, strong) UIView *view4;

-(UIColor*)randomColor;
-(UIView*)createTestView;

-(void)setupTestLayoutWithID:(NSNumber*)layoutID;
@end

@implementation ViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.viewNumber = 1;
    
    self.view1 = [self createTestView];
    self.view2 = [self createTestView];
    self.view3 = [self createTestView];
    self.view4 = [self createTestView];

    [self setupTestLayoutWithID:self.selectedID];
}

-(UIColor*)randomColor
{
    // Thanks: https://gist.github.com/kylefox/1689973
    CGFloat hue = (arc4random_uniform(360) / 360.0);  //  0.0 to 1.0
    CGFloat saturation = ((arc4random_uniform(128) + 1) / 256.0) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ((arc4random_uniform(128) + 1) / 256.0) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

-(UIView*)createTestView
{
    UIView *result = [[UIView alloc] init];
    result.backgroundColor = [self randomColor];
    result.tag = self.viewNumber++;
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:result.frame];
    lbl.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    lbl.text = [NSString stringWithFormat:@"%ld", (long)result.tag];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.font = [UIFont boldSystemFontOfSize:36];
    
    [result addSubview:lbl];
    
    return result;
}

#pragma mark - Demo Layouts
-(void)setupTestLayoutWithID:(NSNumber *)layoutID
{
    // we're not calling retain, promised!
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL testLayoutMethod = NSSelectorFromString([NSString stringWithFormat:@"setupLayout_%@", self.selectedID]);
    [self performSelector:testLayoutMethod];
#pragma clang diagnostic pop
}

-(void)setupLayout_0
{
    [self.gridView addColumnDefinition:[MBGridViewColumnDefinition columnDefinitionWithWidth:100]];
    
    [self.gridView addItem:[MBGridViewItem itemWithView:self.view1 inRow:0 andColumn:0]];
    [self.gridView addItem:[MBGridViewItem itemWithView:self.view2 inRow:0 andColumn:1]];
}

-(void)setupLayout_1
{
    [self.gridView addColumnDefinition:[MBGridViewColumnDefinition columnDefinitionWithWidth:1 andSizeMode:MBGridViewSizeModeStar]];
    [self.gridView addRowDefinition:[MBGridViewRowDefinition rowDefinitionWithHeight:1 andSizeMode:MBGridViewSizeModeStar]];
    
    [self.gridView addItem:[MBGridViewItem itemWithView:self.view1 inRow:0 andColumn:0]];
    [self.gridView addItem:[MBGridViewItem itemWithView:self.view2 inRow:0 andColumn:1]];
    [self.gridView addItem:[MBGridViewItem itemWithView:self.view3 inRow:1 andColumn:0]];
    [self.gridView addItem:[MBGridViewItem itemWithView:self.view4 inRow:1 andColumn:1]];
    
}

@end
