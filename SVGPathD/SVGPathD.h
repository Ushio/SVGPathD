//
//  SVGPathD.h
//  SVGPathD
//
//  Created by Ushio on 2014/12/20.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface SVGPathD : NSObject
- (instancetype)initWithPathD:(NSString *)pathD;
- (CGPathRef)CGPath;
@end
