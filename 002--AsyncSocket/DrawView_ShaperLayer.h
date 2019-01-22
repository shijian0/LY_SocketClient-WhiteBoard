//
//  DrawView_ShaperLayer.h
//  002--AsyncSocket
//
//  Created by 勇 李 on 2017/10/31.
//  Copyright © 2017年 勇 李. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SendPointBlock)(NSMutableArray *points);

@interface DrawView_ShaperLayer : UIImageView
@property (nonatomic,strong)SendPointBlock block;
- (void)back;
- (void)reDo;
- (void)clean;
- (void)addLine:(NSMutableArray*)array;
@end
