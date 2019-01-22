//
//  DrawView_ShaperLayer.m
//  002--AsyncSocket
//
//  Created by 勇 李 on 2017/10/31.
//  Copyright © 2017年 勇 李. All rights reserved.
//

#import "DrawView_ShaperLayer.h"
#import "LYbezierPath.h"
#import "LYShapeLayer.h"
@interface DrawView_ShaperLayer()
@property (nonatomic,strong)NSMutableArray * shapeLayers;
//@property (nonatomic,strong)NSMutableArray * delLayers;

@property (nonatomic,strong)LYShapeLayer * lastLayer;
@property (nonatomic,strong)LYbezierPath * lastPath;

@end

@implementation DrawView_ShaperLayer

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.layer.masksToBounds = YES;
        self.image = [UIImage imageNamed:@"test"];

    }
    return self;
}
//- (void)back{
//    CAShapeLayer * layer = self.shapeLayers.lastObject;
//    [self.delLayers addObject:layer];
//    [layer removeFromSuperlayer];
//    [self.shapeLayers removeLastObject];
//}
//- (void)clean{
//    [self.shapeLayers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(CAShapeLayer*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [obj removeFromSuperlayer];
//        [self.shapeLayers removeObject:obj];
//    }];
//}
//- (void)reDo{
//    CAShapeLayer * layer = self.delLayers.lastObject;
//    [self.delLayers removeLastObject];
//    [self.layer addSublayer:layer];
//}
- (void)touchesBegan:(NSSet<UITouch *> *)touches  withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    LYbezierPath*path = [[LYbezierPath alloc]init];
    [path moveToPoint:p];
    self.lastPath = path;
    LYShapeLayer*shapeLayer = [[LYShapeLayer alloc]init];
    shapeLayer.path = path.CGPath;
    [self.layer addSublayer:shapeLayer];
    self.lastLayer = shapeLayer;
    [self.shapeLayers addObject:shapeLayer];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    [self.lastPath addLineToPoint:p];
    CGPoint relativePoint = [self convertToRelativePoint:p];
    if (relativePoint.x < 0 || relativePoint.x > 1 || relativePoint.y < 0 || relativePoint.y > 1) {
        return;
    }
    NSMutableDictionary * pointDict =[NSMutableDictionary dictionary];
    NSString * x = [NSString stringWithFormat:@"%0.4f",relativePoint.x];
    NSString * y = [NSString stringWithFormat:@"%0.4f",relativePoint.y];
    
    [pointDict setObject:x forKey:@"x"];
    [pointDict setObject:y forKey:@"y"];

    [self.lastLayer.pointList addObject:pointDict];
//    NSLog(@"move:%@",NSStringFromCGPoint(p));
    self.lastLayer.path = self.lastPath.CGPath;
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    NSLog(@"end:%@",NSStringFromCGPoint(p));
    if (self.block) {
        self.block(self.lastLayer.pointList);
    }
}
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.layer.sublayers enumerateObjectsUsingBlock:^(__kindof LYShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LYbezierPath * path = [self getBezierPathWithPointList:obj.pointList];
        ((CAShapeLayer*)obj).path =path.CGPath;
    }];
}
- (LYbezierPath*)getBezierPathWithPointList:(NSArray*)list{
    LYbezierPath*path = [[LYbezierPath alloc]init];
    
    [list enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber* x = [obj objectForKey:@"x"];
        NSNumber* y = [obj objectForKey:@"y"];
        CGPoint p = CGPointMake(x.floatValue,y.floatValue);
        CGPoint point = [self convertToAbsolutePoint:p];
        if (idx == 0) {
            [path moveToPoint:point];
        }else{
            [path addLineToPoint:point];
        }
    }];
    return path;
}
- (void)addLine:(NSMutableArray*)array{
    LYbezierPath*path = [[LYbezierPath alloc]init];
    
    [array enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber* x = [obj objectForKey:@"x"];
        NSNumber* y = [obj objectForKey:@"y"];
        CGPoint p = CGPointMake(x.floatValue,y.floatValue);
        NSLog(@"recv1:%@",NSStringFromCGPoint(p));
        CGPoint point = [self convertToAbsolutePoint:p];
        NSLog(@"recv2:%@",NSStringFromCGPoint(point));
        
        if (idx == 0) {
            [path moveToPoint:point];
        }else{
            [path addLineToPoint:point];
        }
    }];
    LYShapeLayer*shapeLayer = [[LYShapeLayer alloc]init];
    shapeLayer.path = path.CGPath;
    shapeLayer.pointList = array;
    [self.layer addSublayer:shapeLayer];
    [self.shapeLayers addObject:shapeLayer];
    
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}
- (CGPoint )convertToAbsolutePoint:(CGPoint)relativePoint {

    CGSize wxhSize = CGSizeMake(1772,974);
    
    CGFloat xoffset = 0;
    CGFloat yoffset = 0;
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    if (wxhSize.width == 0 || wxhSize.height == 0) {
        
    }else {
        CGFloat ratio = (wxhSize.width * 1.00)/wxhSize.height;
        if (ratio * height > width) {//比当前屏幕扁
            height = width / ratio;
            yoffset = (self.frame.size.height - height) / 2;
        }else {
            width = ratio * height;
            xoffset = (self.frame.size.width - width) / 2;
        }
    }
    CGPoint absolutePoint = CGPointMake(xoffset + relativePoint.x * width, yoffset + relativePoint.y * height);
    return absolutePoint;
}

//绝对点转相对点
- (CGPoint)convertToRelativePoint:(CGPoint)absolutePoint{

    CGSize wxhSize = CGSizeMake(1772,974);

    CGFloat xoffset = 0;
    CGFloat yoffset = 0;

    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;

    if (wxhSize.width == 0 || wxhSize.height == 0) {

    }else {
        CGFloat ratio = (wxhSize.width * 1.00)/wxhSize.height;
        if (ratio * height > width) {//比当前屏幕扁
            height = self.frame.size.width / ratio;
            yoffset = (self.frame.size.height - height) / 2;
        }else {
            width = ratio * height;
            xoffset = (self.frame.size.width - width) / 2;
        }
    }


    CGFloat x = absolutePoint.x - xoffset;
    CGFloat y = absolutePoint.y - yoffset;

    CGPoint relativePoint = CGPointMake(x/width,y/height);

    return relativePoint;
}
- (NSMutableArray*)shapeLayers{
    if (!_shapeLayers) {
        _shapeLayers = [NSMutableArray array];
    }
    return _shapeLayers;
}
//- (NSMutableArray*)delLayers{
//    if (!_delLayers) {
//        _delLayers = [NSMutableArray array];
//    }
//    return _delLayers;
//}

@end
