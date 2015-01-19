//
//  MBGridView.h
//  MBGridViewTest
//
//  Created by Markus Bullmann on 16/01/15.
//  Copyright (c) 2015 Markus Bullmann. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MBGridViewSizeMode) {
    MBGridViewSizeModePoints,
    MBGridViewSizeModeStar,
    MBGridViewSizeModeAutoSize
};

@interface MBGridViewLength : NSObject
@property(nonatomic, readonly) MBGridViewSizeMode sizeMode;
@property(nonatomic, readonly) CGFloat factor;

-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithFactor:(CGFloat)factor andMode:(MBGridViewSizeMode)sizemode;
@end

@interface MBGridViewDefintionBase : NSObject
@property(nonatomic, readonly) MBGridViewLength *value;

-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithGridLenght:(MBGridViewLength*)value;
@end

@interface MBGridViewColumnDefinition : MBGridViewDefintionBase
@property(nonatomic, readonly) CGFloat width;

+(instancetype)autoSizeColumnDefinition;
+(instancetype)columnDefinitionWithWidth:(CGFloat)width;
+(instancetype)columnDefinitionWithWidth:(CGFloat)width andSizeMode:(MBGridViewSizeMode)sizeMode;
@end

@interface MBGridViewRowDefinition : MBGridViewDefintionBase
@property(nonatomic, readonly) CGFloat height;

+(instancetype)autoSizeRowDefinition;
+(instancetype)rowDefinitionWithHeight:(CGFloat)height;
+(instancetype)rowDefinitionWithHeight:(CGFloat)height andSizeMode:(MBGridViewSizeMode)sizeMode;
@end

@interface MBGridViewItem : NSObject
@property(nonatomic, readonly) UIView *view;
@property(nonatomic, readonly) NSUInteger row;
@property(nonatomic, readonly) NSUInteger column;
//@property(nonatomic, readonly) NSUInteger rowSpan;
//@property(nonatomic, readonly) NSUInteger columnSpan;

+(instancetype)itemWithView:(UIView*)view inRow:(NSUInteger)row andColumn:(NSUInteger)column;
@end

@interface MBGridView : UIView

@property(nonatomic, assign) BOOL _showHelpLines; // debug only

@property(nonatomic, readonly) NSArray *items;
@property(nonatomic, readonly) NSArray *rowDefinitions;
@property(nonatomic, readonly) NSArray *columnDefinitions;


-(void)addItem:(MBGridViewItem*)item;
-(void)removeItem:(MBGridViewItem*)item;

-(void)addRowDefinition:(MBGridViewRowDefinition*)rowDefinition;
-(void)addColumnDefinition:(MBGridViewColumnDefinition*)columnDefinition;
-(void)removeColumnDefinition:(MBGridViewColumnDefinition*)columnDefinition;


@end
