//
//  SimpleLayoutTests.m
//  MBGridLayout
//
//  Created by Markus Bullmann on 26/01/15.
//  Copyright (c) 2015 mbulli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Specta.h"
#define EXP_SHORTHAND
#import "Expecta.h"

#import "MBGridView.h"
#import "TestHelper.h"

static const CGFloat GridWidth  = 400;
static const CGFloat GridHeight = 600;

SpecBegin(SimpleLayouts)

describe(@"Simple Layout", ^{
    __block MBGridView *grid;
    __block UIView *view1, *view2, *view3, *view4;
    
    beforeEach(^{
        grid = [[MBGridView alloc] initWithFrame:RECT(0, 0, GridWidth, GridHeight)];
        view1 = [[UIView alloc] init];
        view2 = [[UIView alloc] init];
        view3 = [[UIView alloc] init];
        view4 = [[UIView alloc] init];
    });
    
    it(@"with no column or row definition", ^{
        [grid addItem:[MBGridViewItem itemWithView:view1 inRow:0 andColumn:0]];
        
        performLayout(grid);
        
        expect(view1.frame).to.equal(grid.bounds);
    });
    
    it(@"with 2 fixed columns", ^{
        
    });
    
    it(@"2x2 with equal sizes", ^{
        [grid addColumnDefinition:[MBGridViewColumnDefinition columnDefinitionWithWidth:1 andSizeMode:MBGridViewSizeModeStar]];
        
        [grid addRowDefinition:[MBGridViewRowDefinition rowDefinitionWithHeight:1 andSizeMode:MBGridViewSizeModeStar]];
        
        [grid addItem:[MBGridViewItem itemWithView:view1 inRow:0 andColumn:0]];
        [grid addItem:[MBGridViewItem itemWithView:view2 inRow:0 andColumn:1]];
        [grid addItem:[MBGridViewItem itemWithView:view3 inRow:1 andColumn:0]];
        [grid addItem:[MBGridViewItem itemWithView:view4 inRow:1 andColumn:1]];
        
        performLayout(grid);
        
        CGFloat halfWidth = GridWidth / 2.0;
        CGFloat halfHeight = GridHeight / 2.0;
        
        expect(view1.frame).to.equal(RECT(0,         0,          halfWidth, halfHeight));
        expect(view2.frame).to.equal(RECT(halfWidth, 0,          halfWidth, halfHeight));
        expect(view3.frame).to.equal(RECT(0,         halfHeight, halfWidth, halfHeight));
        expect(view4.frame).to.equal(RECT(halfWidth, halfHeight, halfWidth, halfHeight));
    });
    
});

SpecEnd