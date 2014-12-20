//
//  PathView.h
//  SVGPathD
//
//  Created by Ushio on 2014/12/20.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVGPathD.h"

@interface PathView : UIView
// NSArray of SVGPathD
@property (nonatomic, copy) NSArray *paths;
@end
