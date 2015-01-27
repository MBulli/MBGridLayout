//
//  GridViewItemTests.m
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

SpecBegin(GridViewItem)

describe(@"Grid item", ^{
    __block MBGridView *grid;
    __block UIView *someView;
    
    beforeEach(^{
        grid = [[MBGridView alloc] init];
        someView = [[UIView alloc] init];
    });
    
    it(@"can be created", ^{
        MBGridViewItem *item = [MBGridViewItem itemWithView:someView inRow:0 andColumn:0];
        expect(item).notTo.beNil();
    });
    
    it(@"has valid configuration", ^{
        MBGridViewItem *item = [MBGridViewItem itemWithView:someView inRow:0 andColumn:0];
        
        [grid addItem:item];
        performLayout(grid);
        
        expect(grid.items).to.contain(item);
        expect(grid.subviews).to.contain(someView);
    });
    
    describe(@"will be ignored when invalid ", ^{
        it(@"view is assigend", ^{
            MBGridViewItem *item1 = [MBGridViewItem itemWithView:nil inRow:0 andColumn:0];
            [grid addItem:item1];
            
            performLayout(grid);
            
            expect(grid.items).to.haveCountOf(1);
            expect(grid.subviews).to.beEmpty();
        });
        it(@"row is assigned", ^{
            
        });
        it(@"column is assigned", ^{
            
        });
    });
});

SpecEnd