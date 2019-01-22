//
//  LYbezierPath.m
//  002--AsyncSocket
//
//  Created by 勇 李 on 2017/10/31.
//  Copyright © 2017年 勇 李. All rights reserved.
//

#import "LYbezierPath.h"

@implementation LYbezierPath
- (instancetype)init{
    if (self = [super init]) {
        self.lineCapStyle = kCGLineCapRound;
        self.lineJoinStyle = kCGLineJoinRound;
        self.lineColor = [UIColor redColor];
        self.lineWidth = 2;
    }
    return self;
}
@end
