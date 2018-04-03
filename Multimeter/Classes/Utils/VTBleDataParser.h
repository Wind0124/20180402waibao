//
//  VTBleDataParser.h
//  Multimeter
//
//  Created by vincent on 16/4/11.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTBleLCDModel.h"
#import "VTBleDialModel.h"
#import "VTBleButtonModel.h"

//小数字
typedef struct {
    Byte low;
    Byte high;
    int dot[3];
    int negative;
} LCDSegmentNumber;

typedef struct {
    //数字
    LCDSegmentNumber number;
    
    //功能指示
    //单选
    int V; int A;
    int F;//法拉 不要跟华氏混淆
    int res; //欧
    int Hz;
    int ncv_non_contact_voltage_detection;//非接触测量
    int speaker;//蜂鸣器 代表短路测试功能
    int diode;
    
    //交流直流
    int ac;
    int dc;
    
    //量词
    int n; int u; int m;//电容
    int M; int k; //电阻和频率
    int percent;
    
    
    //温度
    int C0;
    int F0;
    
    
    //功能提示
    int auto_power_off;
    int auto_range;//自动量程模式
    int low_battery;//低电池
    int hold;
    int usb;//usb
    int ble;//蓝牙
    
    int max;
    int min;
    int max_min;
    
    int hFE; // 三级管标志
    int rel; // 相对值标志
    
    // 辅助字段
    int overload;
} LCDSegment;


// 蓝牙数据解析
@interface VTBleDataParser : NSObject {
@public
    LCDSegment _lcddata;
    Byte _buttonState;
}

// 上次解析结果
@property (assign, nonatomic) NSInteger result;

/**
 *  解析数据
 *
 *  @param data 完整的数据包
 *
 *  @return 结果,0成功,其他失败
 */
- (int)parseWithData:(NSData *)data;

// 返回机器型号
- (NSInteger)deviceModel;

- (NSString *)deviceModelName;

// 返回lcd显示数据
- (NSString *)lcdString;
// 符点数值,用来分析图表用
- (float)floatValue;

// 返回单位数据
- (NSString *)unitString;

// 返回功能数据
- (NSString *)funcString;

// 获取量程
- (NSDictionary *)getRange;

// 转成speech可以识别的字串
- (NSString *)convertToSpeechText;

// 返回拔盘旋转位置
- (CGFloat)angle;
- (NSInteger)pointPos;

// 返回lcd按键信息
- (BOOL)isMax;
- (BOOL)isMin;
- (BOOL)isH;
- (BOOL)isBlue;
- (BOOL)isHZ;

// 返回按键信息
- (BOOL)isFuncClick;
- (BOOL)isHoldClick;
- (BOOL)isHZClick;
- (BOOL)isBrightClick;
- (BOOL)isRangeClick;
- (BOOL)isRELClick;
//- (BOOL)isBleClick;

// 低电量标志
- (BOOL)isLowBattery;
// 数据是否有必要显示
- (BOOL)isDrawable;

// 返回拔盘类型
- (NSInteger)dialType;

// 返回拔盘描述信息
- (NSString *)dialString;

// 解析后的数据,用来画表格或曲线
- (NSDictionary *)analyzedDict;

#pragma mark - Tools
+ (NSString *)simpleDialStringWithType:(NSInteger)dialType;
+ (NSString *)trimData:(NSString *)text;
+ (NSString *)unitSpeech:(NSString *)text;

@end

