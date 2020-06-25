//
//  ViewController.m
//  002--AsyncSocket
//
//  Created by 勇 李 on 2017/10/31.
//  Copyright © 2017年 勇 李. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
#import "DrawView_ShaperLayer.h"

//127.0.0.1
static NSString *server_host = @"127.0.0.1";

static const short server_port = 6969;

#define VA_Commadn_id 0x00000001

@interface ViewController ()<GCDAsyncSocketDelegate>
@property (nonatomic,strong)DrawView_ShaperLayer * drawView_ShapeLayer;
@property (strong, nonatomic) GCDAsyncSocket *clientSocket;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initGCDAsyncSocket];
    [self.view addSubview:self.drawView_ShapeLayer];

}

- (void)initGCDAsyncSocket{
    //创建 Socket
    if (_clientSocket == nil) {
        _clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                   delegateQueue:dispatch_get_main_queue()];
    }
}

- (BOOL)connect{
    NSError *error = nil;
    BOOL connectFlag = [_clientSocket connectToHost:server_host onPort:server_port error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    return connectFlag;
}

- (void)disConnect{
    [_clientSocket disconnect];
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h = w/16*9;
    self.drawView_ShapeLayer.frame =  CGRectMake(0, 0, w, h);
    
}
-(DrawView_ShaperLayer*)drawView_ShapeLayer{
    if (!_drawView_ShapeLayer) {
        CGRect f = self.view.frame;
        f.size.height -=40;
        _drawView_ShapeLayer = [[DrawView_ShaperLayer alloc]initWithFrame:f];
        _drawView_ShapeLayer.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        __weak __typeof(self)weakSelf = self;
        _drawView_ShapeLayer.block = ^(NSMutableArray *points) {
            for (int i =0; i<10; i++) {
                 [weakSelf sendPoint:points];
            }
        };
    }
    return _drawView_ShapeLayer;
}
#pragma mark -- GCDAsyncSocketDelegate
//连接成功回调
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"连接成功");
    
    [_clientSocket readDataWithTimeout:-1 tag:0];
}

//断开连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"断开连接%@",err.localizedDescription);
}

//接受消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"接受到消息:(%@)",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    
    [_clientSocket readDataWithTimeout:-1 tag:0];
}

- (void)sendImage{
  //定义数据格式
    
    UIImage *image = [UIImage imageNamed:@"icon_socket"];
    NSData *imageData = UIImagePNGRepresentation(image);
    
    
    NSMutableData *totalData = [NSMutableData data];
    //总长度
    unsigned int totalSize = (int)imageData.length + 4 + 4;
    
    NSData *totalSizeData = [NSData dataWithBytes:&totalSize length:4];
    
    [totalData appendData:totalSizeData];
    
    
    //拼接指令长度
    unsigned int commandId =  VA_Commadn_id;
    
    NSData *commandIdData = [NSData dataWithBytes:&commandId length:4];
    
    [totalData appendData:commandIdData];

    //拼接图片长度
    [totalData appendData:imageData];
    
    [_clientSocket writeData:totalData withTimeout:-1 tag:0];
}


#pragma mark -- Button Action

- (IBAction)connectAction:(UIButton *)sender{
    [self connect];
}

- (IBAction)disConnectAction:(UIButton *)sender{
    [self disConnect];
}
- (void)sendPoint:(NSArray *)pointList{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:pointList options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSData *data = [@"123" dataUsingEncoding:NSUTF8StringEncoding];
    
    [_clientSocket writeData:data withTimeout:-1 tag:0];
}
- (IBAction)sendAction:(UIButton *)sender{
//    NSData *data = [_textField.text dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"发送消息:(%@)",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSData * data = [@"下午好" dataUsingEncoding:NSUTF8StringEncoding];
    NSData * data2 = [@"李勇" dataUsingEncoding:NSUTF8StringEncoding];
    NSData * data3 = [@"请问你下干嘛呢" dataUsingEncoding:NSUTF8StringEncoding];
    NSData * data4 = [@"收到后，请回复" dataUsingEncoding:NSUTF8StringEncoding];
    NSData * data5 = [@"回复啊" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"icon_socket" ofType:@"png"];
    NSData *data6 = [NSData dataWithContentsOfFile:filePath];
    [self sendData:[self packageData:data type:@"text"]];
    [self sendData:[self packageData:data2 type:@"text"]];
    [self sendData:[self packageData:data3 type:@"text"]];
    [self sendData:[self packageData:data4 type:@"text"]];
    [self sendData:[self packageData:data5 type:@"text"]];
    [self sendData:[self packageData:data6 type:@"img"]];

    
   //测试封包，注释下面
//    NSArray * ar = @[@"000008",@"000725"];
//
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:ar options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//
//    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//
//    [_clientSocket writeData:data withTimeout:-1 tag:0];
    
}
- (NSData *)packageData:(NSData *)data type:(NSString *)type{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSString stringWithFormat:@"%lu",(unsigned long)data.length] forKey:@"size"];
    [dict setObject:type forKey:@"type"];
    NSString * jsonString = [self dictToJsonString:dict];
    NSData * headerData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData * mutData = [NSMutableData dataWithData:headerData];
    [mutData appendData:[GCDAsyncSocket CRLFData]];
     
    [mutData appendData:data];
    
    return mutData;
}
- (NSString *)dictToJsonString:(NSMutableDictionary *)dict{
    NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}
- (void)sendData:(NSData *)data{
      [_clientSocket writeData:data withTimeout:-1 tag:0];
}
- (IBAction)sendImageAction:(id)sender {
    [self sendImage];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
