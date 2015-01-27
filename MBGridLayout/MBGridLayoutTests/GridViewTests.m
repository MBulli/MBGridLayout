//
//  MBGridLayoutTests.m
//  MBGridLayoutTests
//
//  Created by Markus Bullmann on 18/01/15.
//  Copyright (c) 2015 mbulli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Specta.h"
#define EXP_SHORTHAND
#import "Expecta.h"

#import "MBGridView.h"

SpecBegin(GridView)

describe(@"GridView", ^{
    __block MBGridView *grid;
    
    beforeEach(^{
        grid = [[MBGridView alloc] init];
    });
    
    
    it(@"can be created", ^{
        expect(grid).toNot.beNil;
    });
    
    it(@"has an implicit star column", ^{
        MBGridViewColumnDefinition *columnDef = [grid.columnDefinitions firstObject];
        
        expect(grid.columnDefinitions).to.haveCountOf(1);
        expect(columnDef).toNot.beNil();
        expect(columnDef).to.beKindOf([MBGridViewColumnDefinition class]);

        expect(columnDef.value.sizeMode).to.equal(MBGridViewSizeModeStar);
        expect(columnDef.value.factor).to.equal(1);
    });

    it(@"has an implicit star row", ^{
        MBGridViewRowDefinition *rowDef = [grid.rowDefinitions firstObject];
        
        expect(grid.rowDefinitions).to.haveCountOf(1);
        expect(rowDef).toNot.beNil();
        expect(rowDef).to.beKindOf([MBGridViewRowDefinition class]);

        expect(rowDef.value.sizeMode).to.equal(MBGridViewSizeModeStar);
        expect(rowDef.value.factor).to.equal(1);
    });
});

SpecEnd