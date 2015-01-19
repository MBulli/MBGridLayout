//
//  MBGridView.m
//  MBGridViewTest
//
//  Created by Markus Bullmann on 16/01/15.
//  Copyright (c) 2015 Markus Bullmann. All rights reserved.
//

#import "MBGridView.h"

typedef struct MBGridViewColumnTuple {
    CGFloat minX;
    CGFloat width;
    __unsafe_unretained MBGridViewColumnDefinition *definition;
} MBGridViewColumnTuple;

typedef struct MBGridViewRowTuple {
    CGFloat minY;
    CGFloat height;
    __unsafe_unretained MBGridViewRowDefinition *definition;
} MBGridViewRowTuple;

static inline CGFloat MBGridViewColumnTupleGetMaxX(MBGridViewColumnTuple col)
{
    return col.minX + col.width;
}

static inline CGFloat MBGridViewRowTupleGetMaxY(MBGridViewRowTuple row)
{
    return row.minY + row.height;
}

@interface MBGridViewImplicitColumnDefinition : MBGridViewColumnDefinition
+(instancetype)sharedInstance;
@end

@interface MBGridViewImplicitRowDefinition : MBGridViewRowDefinition
+(instancetype)sharedInstance;
@end



@interface MBGridView ()
{
    @private
    NSMutableArray *_items;
    NSMutableArray *_rowDefinitions;
    NSMutableArray *_columnDefinitions;
}

-(void)configureView;

-(CGFloat)columnWidthAtIndex:(NSUInteger)columnIndex;
-(CGFloat)rowHeightAtIndex:(NSUInteger)rowIndex;

-(void)renderGridHelpLines:(MBGridViewColumnTuple*)columns columnCount:(NSUInteger)columnCount rows:(MBGridViewRowTuple*)rows rowCount:(NSUInteger)rowCount;
@end

@implementation MBGridView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureView];
    }
    return self;
}

-(void)configureView
{
    _items = [NSMutableArray array];
    _rowDefinitions = [NSMutableArray array];
    _columnDefinitions = [NSMutableArray array];
    
    // We need at least one definition
    // The last definition is always a filler with 1*
    [_rowDefinitions addObject:[MBGridViewImplicitRowDefinition sharedInstance]];
    [_columnDefinitions addObject:[MBGridViewImplicitColumnDefinition sharedInstance]];
}

#pragma mark - Item managment
-(NSArray *)items
{
    return _items;
}

-(NSArray *)rowDefinitions
{
    return _rowDefinitions;
}

-(NSArray *)columnDefinitions
{
    return _columnDefinitions;
}

-(void)addItem:(MBGridViewItem *)item
{
    if (item) {
        [_items addObject:item];
        [self setNeedsLayout];
    }
}

-(void)removeItem:(MBGridViewItem *)item
{
    if (item) {
        [_items removeObject:item];
        [self setNeedsLayout];
    }
}

-(void)addRowDefinition:(MBGridViewRowDefinition *)rowDefinition
{
    NSAssert(![rowDefinition isKindOfClass:[MBGridViewImplicitRowDefinition class]], @"Can not add implicit definition.");
    
    if (rowDefinition) {
        // Ensure that the implicit definition is always the last definition
        [_rowDefinitions insertObject:rowDefinition atIndex:(_rowDefinitions.count - 1)];
        [self setNeedsLayout];
    }
}

-(void)addColumnDefinition:(MBGridViewColumnDefinition *)columnDefinition
{
    NSAssert(![columnDefinition isKindOfClass:[MBGridViewImplicitColumnDefinition class]], @"Can not add implicit definition.");
    
    if (columnDefinition) {
        // Ensure that the implicit definition is always the last definition
        // TODO: insert copy
        [_columnDefinitions insertObject:columnDefinition atIndex:(_columnDefinitions.count - 1)];
        [self setNeedsLayout];
    }
}

-(void)removeColumnDefinition:(MBGridViewColumnDefinition *)columnDefinition
{
    NSAssert(![columnDefinition isKindOfClass:[MBGridViewImplicitColumnDefinition class]], @"Can not remove implicit definition.");

    if (columnDefinition) {
        [_columnDefinitions removeObject:columnDefinition];
        [self setNeedsLayout];
    }
}


#pragma mark - Layout
-(void)set_showHelpLines:(BOOL)_showHelpLines
{
    __showHelpLines = _showHelpLines;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    // check some asumptions.
    NSAssert(self.columnDefinitions.count > 0, @"There should be always at least one definition.");
    NSAssert(self.rowDefinitions.count > 0, @"There should be always at least one definition.");
    
    NSAssert([self.columnDefinitions lastObject] == [MBGridViewImplicitColumnDefinition sharedInstance], @"Last column must be implicit");
    NSAssert([self.rowDefinitions    lastObject] == [MBGridViewImplicitRowDefinition sharedInstance], @"Last row must be implicit");
    
    const CGRect bounds = self.bounds;
    
    NSLog(@"grid.bounds=%@", NSStringFromCGRect(bounds));
    
    NSUInteger columnCount = self.columnDefinitions.count;
    NSUInteger rowCount = self.rowDefinitions.count;

    MBGridViewColumnTuple columns[columnCount];
    MBGridViewRowTuple rows[rowCount];
    
    CGFloat sumNonStarWidth = 0;
    CGFloat sumNonStarHeight = 0;
    
    CGFloat sumStarFactorsHorizontal = 0; // the sum of all sum factors in the column definitions
    CGFloat sumStarFactorsVertical = 0;
    
    // 1. pass - calculate row/column values for none star row/columns
    for (int c = 0; c < columnCount; c++) {
        CGFloat width = [self columnWidthAtIndex:c];
        MBGridViewColumnDefinition *defintion = self.columnDefinitions[c];

        if (defintion.value.sizeMode == MBGridViewSizeModeStar) {
            sumStarFactorsHorizontal += width;
        } else {
            sumNonStarWidth += width;
        }
        
        columns[c].width = width;
        columns[c].definition = defintion;
    }
    
    for (int r = 0; r < rowCount; r++) {
        CGFloat height = [self rowHeightAtIndex:r];
        MBGridViewRowDefinition *defintion = self.rowDefinitions[r];
        
        if (defintion.value.sizeMode == MBGridViewSizeModeStar) {
            sumStarFactorsVertical += height;
        } else {
            sumNonStarHeight += height;
        }
        
        rows[r].height = height;
        rows[r].definition = defintion;
    }
    
    CGFloat starWidthRemainder = bounds.size.width - sumNonStarWidth;
    CGFloat starHeightRemainder = bounds.size.height - sumNonStarHeight;
    
    // 2. pass - calculate star fractions
    // for columns
    for (int c2 = 0; c2 < columnCount; c2++) {
        if (columns[c2].definition.value.sizeMode == MBGridViewSizeModeStar) {
            // calculate width for star
            CGFloat starWidth = (starWidthRemainder / sumStarFactorsHorizontal) * columns[c2].definition.width;
            columns[c2].width = starWidth;
        }
        
        // set minX
        if (c2 == 0) {
            columns[c2].minX = 0;
        } else {
            columns[c2].minX = MBGridViewColumnTupleGetMaxX(columns[c2 - 1]);
        }
    }
    
    // and for rows
    for (int r2 = 0; r2 < rowCount; r2++) {
        if (rows[r2].definition.value.sizeMode == MBGridViewSizeModeStar) {
            CGFloat starHeight= (starHeightRemainder / sumStarFactorsVertical) * rows[r2].definition.height;
            rows[r2].height = starHeight;
        }
        
        if (r2 == 0) {
            rows[r2].minY = 0;
        } else {
            rows[r2].minY = MBGridViewRowTupleGetMaxY(rows[r2 - 1]);
        }
    }
    
    
    // 3. pass - enum all items and set frames
    for (int itemIndex = 0; itemIndex < self.items.count; itemIndex++) {
        MBGridViewItem *item = self.items[itemIndex];

        // check if item has a valid configuration
        // this implies, that we never have to do bound checks for rows&colums inside this loop
        if (!item.view || item.row > self.rowDefinitions.count || item.column > self.columnDefinitions.count) {
            [item.view removeFromSuperview];
            continue;
        }
        
    
        // if items view is not already a subview, add it
        if (item.view.superview != self) {
            [self insertSubview:item.view atIndex:itemIndex];
        }

        CGRect itemFrame = CGRectMake(columns[item.column].minX, rows[item.row].minY, 0, 0);
        
        if (columns[item.column].definition.value.sizeMode != MBGridViewSizeModeAutoSize) {
            itemFrame.size.width = columns[item.column].width;
        } else {
            itemFrame.size.width = item.view.frame.size.width;
        }
        
        if (rows[item.row].definition.value.sizeMode != MBGridViewSizeModeAutoSize) {
            itemFrame.size.height = rows[item.row].height;
        } else {
            itemFrame.size.height = item.view.frame.size.height;
        }
        
        item.view.frame = itemFrame;
        NSLog(@"item at %d frame=%@", itemIndex, NSStringFromCGRect(item.view.frame));
    }
    
#if DEBUG
    if (self._showHelpLines) {
        [self renderGridHelpLines:columns columnCount:columnCount rows:rows rowCount:rowCount];
    }
#endif
}

-(CGFloat)columnWidthAtIndex:(NSUInteger)columnIndex
{
    MBGridViewColumnDefinition *colDef = self.columnDefinitions[columnIndex];
    
    if (colDef.value.sizeMode == MBGridViewSizeModeAutoSize) {
        // find widest view in column
        CGFloat maxWidth = 0;
        for (MBGridViewItem *item in self.items) {
            if (item.column == columnIndex) {
                maxWidth = MAX(CGRectGetWidth(item.view.frame), maxWidth);
            }
        }
        
        return maxWidth;
    } else {
        return colDef.width;
    }
}

-(CGFloat)rowHeightAtIndex:(NSUInteger)rowIndex
{
    MBGridViewRowDefinition *rowDef = self.rowDefinitions[rowIndex];
    
    if (rowDef.value.sizeMode == MBGridViewSizeModeAutoSize) {
        // find tallest view in row
        CGFloat maxHeight = 0;
        for (MBGridViewItem *item in self.items) {
            if (item.row == rowIndex) {
                maxHeight = MAX(CGRectGetHeight(item.view.frame), maxHeight);
            }
        }
        
        return maxHeight;
    } else {
        return rowDef.height;
    }
}



-(void)renderGridHelpLines:(MBGridViewColumnTuple*)columns columnCount:(NSUInteger)columnCount rows:(MBGridViewRowTuple*)rows rowCount:(NSUInteger)rowCount
{
#if DEBUG
    static UIView *lineContainer = nil;
    
    // remove old helper lines
    [lineContainer removeFromSuperview];
    lineContainer = nil;
    
    if (!columns && !rows) {
        // nothing to do
        return;
    }
    
    // create new container
    lineContainer = [[UIView alloc] initWithFrame:self.bounds];
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if (columns) {
        // skip first column/row because minX is always == 0
        for (NSUInteger i = 1; i < columnCount; i++) {
            [path moveToPoint:   CGPointMake(columns[i].minX, CGRectGetMinY(self.bounds))];
            [path addLineToPoint:CGPointMake(columns[i].minX, CGRectGetMaxY(self.bounds))];
        }
    }
    
    if (rows) {
        for (NSUInteger i = 1; i < rowCount; i++) {
            [path moveToPoint:   CGPointMake(CGRectGetMinX(self.bounds), rows[i].minY)];
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(self.bounds), rows[i].minY)];
        }
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = [[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] CGColor];
    
    [lineContainer.layer addSublayer:shapeLayer];
    [self insertSubview:lineContainer atIndex:NSIntegerMax];
    
#endif // DEBUG
}


@end


@implementation MBGridViewItem

+(instancetype)itemWithView:(UIView *)view inRow:(NSUInteger)row andColumn:(NSUInteger)column
{
    MBGridViewItem *result = [[MBGridViewItem alloc] init];
    result->_view = view;
    result->_row = row;
    result->_column = column;
    
    return result;
}

@end

@implementation MBGridViewLength
-(instancetype)initWithFactor:(CGFloat)factor andMode:(MBGridViewSizeMode)sizemode
{
    NSParameterAssert(isnormal(factor) || factor == 0.0f);
    self = [super init];
    if (self) {
        _factor = factor;
        _sizeMode = sizemode;
    }
    return self;
}
@end

@implementation MBGridViewDefintionBase
-(instancetype)initWithGridLenght:(MBGridViewLength *)value
{
    NSParameterAssert(value);
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}
@end

@implementation MBGridViewColumnDefinition

-(CGFloat)width
{
    return self.value.factor;
}

+(instancetype)autoSizeColumnDefinition
{
    return [self columnDefinitionWithWidth:0 andSizeMode:MBGridViewSizeModeAutoSize];
}

+(instancetype)columnDefinitionWithWidth:(CGFloat)width
{
    return [self columnDefinitionWithWidth:width andSizeMode:MBGridViewSizeModePoints];
}

+(instancetype)columnDefinitionWithWidth:(CGFloat)width andSizeMode:(MBGridViewSizeMode)sizeMode
{
    id value = [[MBGridViewLength alloc] initWithFactor:width andMode:sizeMode];
    return [[MBGridViewColumnDefinition alloc] initWithGridLenght:value];
}

@end

@implementation MBGridViewRowDefinition

-(CGFloat)height
{
    return self.value.factor;
}

+(instancetype)autoSizeRowDefinition
{
    return [self rowDefinitionWithHeight:1 andSizeMode:MBGridViewSizeModeAutoSize];
}

+(instancetype)rowDefinitionWithHeight:(CGFloat)height
{
    return [self rowDefinitionWithHeight:height andSizeMode:MBGridViewSizeModePoints];
}

+(instancetype)rowDefinitionWithHeight:(CGFloat)height andSizeMode:(MBGridViewSizeMode)sizeMode
{
    id value = [[MBGridViewLength alloc] initWithFactor:height andMode:sizeMode];
    return [[MBGridViewRowDefinition alloc] initWithGridLenght:value];
}
@end


@implementation MBGridViewImplicitColumnDefinition

+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static id sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithGridLenght:[[MBGridViewLength alloc] initWithFactor:1 andMode:MBGridViewSizeModeStar]];
    });
    return sharedInstance;
}

@end

@implementation MBGridViewImplicitRowDefinition

+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static id sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithGridLenght:[[MBGridViewLength alloc] initWithFactor:1 andMode:MBGridViewSizeModeStar]];
    });
    return sharedInstance;
}
@end