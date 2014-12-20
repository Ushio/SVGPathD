//
//  CollectionViewCell.h
//  SVGPathD
//
//  Created by Ushio on 2014/12/20.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PathView.h"
@interface CollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet PathView *pathView;
@end
