//
//  PathView.m
//  SVGPathD
//
//  Created by Ushio on 2014/12/20.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import "PathView.h"

static const double kSVGBaseSize = 512;

@implementation PathView
{
    
}
- (void)setPaths:(NSArray *)paths {
    _paths = [paths copy];
    
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextFillEllipseInRect(context, self.bounds);
    
    CGContextScaleCTM(context, self.bounds.size.width / kSVGBaseSize, self.bounds.size.height / kSVGBaseSize);
    
    for(SVGPathD *p in _paths) {
        CGContextAddPath(context, [p CGPath]);
        CGContextFillPath(context);
        //CGContextStrokePath(context);
    }
}

@end
