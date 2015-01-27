//
//  TestHelper.h
//  MBGridLayout
//
//  Created by Markus Bullmann on 26/01/15.
//  Copyright (c) 2015 mbulli. All rights reserved.
//

#define RECT(x,y,w,h) CGRectMake(x,y,w,h)

static inline void performLayout(UIView *v)
{
    [v setNeedsLayout];
    [v layoutIfNeeded];
}
