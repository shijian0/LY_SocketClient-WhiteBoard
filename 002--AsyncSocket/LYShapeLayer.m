//
//  LYShapeLayer.m
//  002--AsyncSocket
//
//  Created by 勇 李 on 2017/10/31.
//  Copyright © 2017年 勇 李. All rights reserved.
//

#import "LYShapeLayer.h"
#import <UIKit/UIKit.h>

@implementation LYShapeLayer
- (instancetype)init{
    if (self = [super init]) {
        self.lineCap = kCALineCapRound;
        self.lineJoin = kCALineJoinRound;
        self.fillColor = [UIColor clearColor].CGColor;
        self.strokeColor = [UIColor redColor].CGColor;
        self.lineWidth = 2;
    }
    return self;
}
- (NSMutableArray*)pointList{
    if (!_pointList) {
        _pointList = [NSMutableArray array];
    }
    return _pointList;
}
@end
