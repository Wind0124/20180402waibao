//
//  VTBleDataParser.m
//  Multimeter
//
//  Created by vincent on 16/4/11.
//  Copyright © 2016年 vincent. All rights reserved.
//

#import "VTBleDataParser.h"
#import "VTBleDataAdapters.h"
#import "VTDeviceMgr.h"
#import "CrcTool.h"

#pragma mark - 之前的万用表解析规则，待优化

static NSArray<NSString *> *gDialStrings = nil;

#pragma mark - 万用表规约解析

#define GETBIT(data, bit) (((data) >> (bit)) & 1)
#define BCD2DEC(data) ((((data)>>4)&0xF)*10+((data)&0xF))

// 一位数字转成对应的char
char bcd2Char(Byte byte) {
    if (byte>=0 && byte<=9) {
        return '0'+byte;
    } else if (byte>=0xA && byte<=0xF) {
        return 'A'+(byte-10);
    } else {
        return ' ';
    }
}

@implementation VTBleDataParser {
    NSInteger _fullDataLength;
    NSInteger _deviceModel;
    Byte _dialState;
    
    NSMutableData *_bufferData;         // 超过18字节的头,缓存起来,避免粘包问题
    NSObject<VTBleDataAdapter> *_adapter;
//    LCDSegmentNumber _lastHoldNumber;
    LCDSegment _lastSegment;    // 进入hold前的数据
    BOOL _haveSaveOneSegment;    // 进入hold前的数据
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    _bufferData = [NSMutableData new];
    
    return self;
}

+ (void)initialize {
    if (!gDialStrings) {
        gDialStrings = @[
                         ];
    }
}

// bcd转数字
- (float)parseNumber: (LCDSegmentNumber *)pLCDSegmentNumber {
    Byte low = pLCDSegmentNumber->low;
    Byte high = pLCDSegmentNumber->high;
    
    int number = BCD2DEC(high)*100 + BCD2DEC(low);
    float floatNum = number;
    
    if(pLCDSegmentNumber->negative)
        floatNum *= -1;
    
    if(pLCDSegmentNumber->dot[0])
        floatNum /= 10;
    else if(pLCDSegmentNumber->dot[1])
        floatNum /= 100;
    else if(pLCDSegmentNumber->dot[2])
        floatNum /= 1000;
    
    return floatNum;
}

- (NSString *) parseLcdLabelNumber: (LCDSegmentNumber *)pLCDSegmentNumber isNcv:(BOOL)yesOrNO {
    char c_number[4];
    char c_sign;
    NSString *tempString;
    
    tempString = @"";
    Byte low = pLCDSegmentNumber->low;
    Byte high = pLCDSegmentNumber->high;
    
    // 数据是FFFF的情况
    if(_lcddata.overload == YES) {
        tempString = @"0.L";
        return tempString;
    }
    // ncv情况
    if(yesOrNO && (pLCDSegmentNumber->low == 0)&&(pLCDSegmentNumber->high== 0)){
        tempString = @"EF";
        return tempString;
    }
    
    //符号
    if(pLCDSegmentNumber->negative)
        c_sign = '-';
    else
        c_sign = ' ';
    
    tempString = [NSString stringWithFormat:@"%@%c", tempString, c_sign];
    
    c_number[3] = bcd2Char((high>>4)&0xF);
    c_number[2] = bcd2Char(high&0xF);
    c_number[1] = bcd2Char((low>>4)&0xF);
    c_number[0] = bcd2Char(low&0xF);
    
    //数字
    tempString = [NSString stringWithFormat:@"%@%c", tempString, c_number[3]];
    if(pLCDSegmentNumber->dot[2])
        tempString = [NSString stringWithFormat:@"%@.", tempString];
    tempString = [NSString stringWithFormat:@"%@%c", tempString, c_number[2]];
    if(pLCDSegmentNumber->dot[1])
        tempString = [NSString stringWithFormat:@"%@.", tempString];
    tempString = [NSString stringWithFormat:@"%@%c", tempString, c_number[1]];
    if(pLCDSegmentNumber->dot[0])
        tempString = [NSString stringWithFormat:@"%@.", tempString];
    tempString = [NSString stringWithFormat:@"%@%c", tempString, c_number[0]];
    
    return tempString;
}

- (NSString*) parseSegFunction: (LCDSegment *)pLcdData {
    NSString *tempString;
    
    // 作兼容
    if ([_adapter respondsToSelector:@selector(segFunction)]) {
        tempString = [_adapter segFunction];
        if (tempString.length) return tempString;
    }
    
    //交直流电压 交直流电流 电阻 短路测试 电容 频率
    if(pLcdData->speaker){//短路测试
        tempString =  @"Continuity";
    }
    else if(pLcdData->diode){//二极管导通电压
        tempString =  @"Diode Test";
    }
    else if(pLcdData->V){
        tempString = @"Voltage";
    }
    else if(pLcdData->A){
        tempString =  @"Current";
    }
    else if(pLcdData->res){
        tempString = @"Resistance";
    }
    
    else if(pLcdData->F){
        tempString = @"Capacitance";
    }
    else if(pLcdData->Hz){
        tempString = @"Frequency";
    }
    else if(pLcdData->C0)
        tempString = @"Temperature";
    else if(pLcdData->F0)
        tempString = @"Temperature";
    else if(pLcdData->percent)
        tempString = @"Duty Cycle";
    else if(pLcdData->ncv_non_contact_voltage_detection){
        tempString = @"NCV";
    }
    else if (pLcdData->hFE) {
        tempString = @"Tramsistor";
    }
    else
        tempString = @"";
    
    if(pLcdData->ac)
        tempString = [NSString stringWithFormat:@"%@ %@", @"AC", tempString];
    else if(pLcdData->dc)
        tempString = [NSString stringWithFormat:@"%@ %@", @"DC", tempString];
    
    return tempString;
}


- (NSString*) parseSegUnit: (LCDSegment *)pLcdData {
    NSString *tempString = @"";
    
    //交直流电压 交直流电流 电阻 短路测试 电容 频率
    if((pLcdData->V)||(pLcdData->A)){
        if (pLcdData->u) {
            tempString = @"μ";
        }
        else if (pLcdData->m) {
            tempString = @"m";
        }
        else
            tempString = @"";
        
        if(pLcdData->V)
            tempString = [NSString stringWithFormat:@"%@%@", tempString, @"V"];
        else if(pLcdData->A)
            tempString = [NSString stringWithFormat:@"%@%@", tempString, @"A"];
    }
    else if(pLcdData->F){
        if (pLcdData->n) {
            tempString = @"n";
        }
        else if (pLcdData->u) {
            tempString = @"u";
        }
        else if (pLcdData->m) {
            tempString = @"m";
        }
        else
            tempString = @"";
        
        tempString = [NSString stringWithFormat:@"%@%@", tempString, @"F"];
    }
    else if((pLcdData->res)||(pLcdData->Hz)){
        if (pLcdData->M) {
            tempString = @"M";
        }
        else if (pLcdData->k) {
            tempString = @"K";
        }
        else
            tempString = @"";
        
        if(pLcdData->res)
            tempString = [NSString stringWithFormat:@"%@%@", tempString, @"Ω"];
        else
            tempString = [NSString stringWithFormat:@"%@%@", tempString, @"Hz"];
    }
    else if(pLcdData->C0)
        tempString = @"°C";
    else if(pLcdData->F0)
        tempString = @"°F";
    else if(pLcdData->percent)
        tempString = @"%";
    else
        tempString = @"";
    
    return tempString;
}

// Wind 解析主LCD数据
- (void)parseLCDData: (NSData*)data {
    char *pdata = (char*)data.bytes;
    int temp = 0;
    
    temp = *pdata++;
    memset(&_lcddata, 0, sizeof(_lcddata));
    //0 low 数码管低两位
    _lcddata.number.low = temp;
    
    //1 high 数码管高两位
    temp = *pdata++;
    _lcddata.number.high = temp;
    
    
    if((_lcddata.number.high == 0xFF)&&(_lcddata.number.low == 0xFF)){
        _lcddata.overload = YES;
    } else {
        _lcddata.overload = NO;
    }
    
    //2 Data11
    temp = *pdata++;
    NSLog(@"Wind %i",temp);
    _lcddata.auto_range = GETBIT(temp, 0);
    _lcddata.max_min = GETBIT(temp, 1);
    _lcddata.min = GETBIT(temp, 2);
    _lcddata.max = GETBIT(temp, 3);
    _lcddata.number.dot[0] = GETBIT(temp, 4);
    _lcddata.number.dot[1] = GETBIT(temp, 5);
    _lcddata.number.dot[2] = GETBIT(temp, 6);
    _lcddata.number.negative = GETBIT(temp, 7);
    
    //3 Data12
    temp = *pdata++;
    _lcddata.A = GETBIT(temp, 0);
    _lcddata.F = GETBIT(temp, 1);
    _lcddata.m = GETBIT(temp, 2);
    _lcddata.u = GETBIT(temp, 3);
    _lcddata.n = GETBIT(temp, 4);
    _lcddata.speaker = GETBIT(temp, 5);
    _lcddata.diode = GETBIT(temp, 6);
    _lcddata.low_battery = GETBIT(temp, 7);
    
    //4 Data13
    temp = *pdata++;
    _lcddata.percent = GETBIT(temp, 0);
    _lcddata.Hz = GETBIT(temp, 1);
    _lcddata.res = GETBIT(temp, 2);
    _lcddata.M = GETBIT(temp, 3);
    _lcddata.k = GETBIT(temp, 4);
    _lcddata.V = GETBIT(temp, 5);
    _lcddata.ac = GETBIT(temp, 6);
    _lcddata.dc = GETBIT(temp, 7);
    
    //5 Data14
    temp = *pdata++;
    _lcddata.hFE = GETBIT(temp, 0);
    _lcddata.auto_power_off = GETBIT(temp, 1);
    _lcddata.rel = GETBIT(temp, 2);
    _lcddata.usb = GETBIT(temp, 3);
    _lcddata.F0 = GETBIT(temp, 4);
    _lcddata.C0 = GETBIT(temp, 5);
    _lcddata.ncv_non_contact_voltage_detection = GETBIT(temp, 6);
    _lcddata.hold = GETBIT(temp, 7);
    
    // 数据设置为之前的数据
    if (_lcddata.hold==1 && _haveSaveOneSegment) {
        _lcddata = _lastSegment;
        _lcddata.hold = 1;
        return;
    }
    _lastSegment = _lcddata;
    _haveSaveOneSegment = YES;
    
    //6 Data15
    temp = *pdata++;
    _lcddata.Wh = GETBIT(temp, 0);
    _lcddata.VAr = GETBIT(temp, 1);
    _lcddata.VA = GETBIT(temp, 2);
    _lcddata.inrush = GETBIT(temp, 3);
    _lcddata.LOZ = GETBIT(temp, 4);
    _lcddata.warning = GETBIT(temp, 5);
    _lcddata.TRMS = GETBIT(temp, 6);
    _lcddata.A_HOLD = GETBIT(temp, 7);
    
    //7 Data16
    temp = *pdata++;
    _lcddata.phaseSign = GETBIT(temp, 0);
    _lcddata.THD = GETBIT(temp, 1);
    _lcddata.LAG = GETBIT(temp, 2);
    _lcddata.LEAD = GETBIT(temp, 3);
    _lcddata.COS = GETBIT(temp, 4);
    _lcddata.SIN = GETBIT(temp, 5);
    _lcddata.PHASE = GETBIT(temp, 6);
    _lcddata.PEAK = GETBIT(temp, 7);
    
    //8 Data17
    temp = *pdata++;
    _lcddata.MEM = GETBIT(temp, 0);
    _lcddata.REC = GETBIT(temp, 1);
    _lcddata.MENU = GETBIT(temp, 2);
    _lcddata.RAN = GETBIT(temp, 3);
    _lcddata.battery25 = GETBIT(temp, 4);
    _lcddata.battery50 = GETBIT(temp, 5);
    _lcddata.battery75 = GETBIT(temp, 6);
    _lcddata.battery100 = GETBIT(temp, 7);

    //9 Data18 保留
}

// Wind 解析副一LCD数据
- (void)parseLCDData1:(NSData *)data {
    char *pdata = (char*)data.bytes;
    int temp = 0;
    
    temp = *pdata++;
    memset(&_lcddata1, 0, sizeof(_lcddata1));
    //0 low 数码管低两位 Data19
    _lcddata1.number.low = temp;
    
    //1 high 数码管高两位 Data20
    temp = *pdata++;
    _lcddata1.number.high = temp;
    
    
    if((_lcddata1.number.high == 0xFF)&&(_lcddata1.number.low == 0xFF)){
        _lcddata1.overload = YES;
    } else {
        _lcddata1.overload = NO;
    }
    
    //2 Data21
    temp = *pdata++;
    NSLog(@"Wind %i",temp);
    _lcddata1.DIF = GETBIT(temp, 0);
    _lcddata1.max_min = GETBIT(temp, 1);
    _lcddata1.min = GETBIT(temp, 2);
    _lcddata1.max = GETBIT(temp, 3);
    _lcddata1.number.dot[0] = GETBIT(temp, 4);
    _lcddata1.number.dot[1] = GETBIT(temp, 5);
    _lcddata1.number.dot[2] = GETBIT(temp, 6);
    _lcddata1.number.negative = GETBIT(temp, 7);
    
    //3 Data22
    temp = *pdata++;
    _lcddata1.A = GETBIT(temp, 0);
    _lcddata1.F = GETBIT(temp, 1);
    _lcddata1.m = GETBIT(temp, 2);
    _lcddata1.u = GETBIT(temp, 3);
    _lcddata1.n = GETBIT(temp, 4);
//    _lcddata1.speaker = GETBIT(temp, 5);
//    _lcddata1.diode = GETBIT(temp, 6);
    _lcddata1.low_battery = GETBIT(temp, 7);
    
    //4 Data23
    temp = *pdata++;
    _lcddata1.percent = GETBIT(temp, 0);
    _lcddata1.Hz = GETBIT(temp, 1);
    _lcddata1.res = GETBIT(temp, 2);
    _lcddata1.M = GETBIT(temp, 3);
    _lcddata1.k = GETBIT(temp, 4);
    _lcddata1.V = GETBIT(temp, 5);
    _lcddata1.ac = GETBIT(temp, 6);
    _lcddata1.dc = GETBIT(temp, 7);
    
    //5 Data24
    temp = *pdata++;
    _lcddata1.H__ = GETBIT(temp, 0);
    _lcddata1.Wh = GETBIT(temp, 1);
    _lcddata1.VAr = GETBIT(temp, 2);
    _lcddata1.VA = GETBIT(temp, 3);
    _lcddata1.F0 = GETBIT(temp, 4);
    _lcddata1.C0 = GETBIT(temp, 5);
    _lcddata1.H__F = GETBIT(temp, 6);
    _lcddata1.H__R = GETBIT(temp, 7);
    
}

// Wind 解析副二LCD数据
- (void)parseLCDData2:(NSData *)data {
    char *pdata = (char*)data.bytes;
    int temp = 0;
    
    temp = *pdata++;
    memset(&_lcddata2, 0, sizeof(_lcddata2));
    //0 low 数码管低两位 Data25
    _lcddata2.number.low = temp;
    
    //1 high 数码管高两位 Data26
    temp = *pdata++;
    _lcddata2.number.high = temp;
    
    
    if((_lcddata2.number.high == 0xFF)&&(_lcddata2.number.low == 0xFF)){
        _lcddata2.overload = YES;
    } else {
        _lcddata2.overload = NO;
    }
    
    //2 Data27
    temp = *pdata++;
    NSLog(@"Wind %i",temp);
//    _lcddata2.DIF = GETBIT(temp, 0);
    _lcddata2.max_min = GETBIT(temp, 1);
    _lcddata2.min = GETBIT(temp, 2);
    _lcddata2.max = GETBIT(temp, 3);
    _lcddata2.number.dot[0] = GETBIT(temp, 4);
    _lcddata2.number.dot[1] = GETBIT(temp, 5);
    _lcddata2.number.dot[2] = GETBIT(temp, 6);
    _lcddata2.number.negative = GETBIT(temp, 7);
    
    //3 Data28
    temp = *pdata++;
    _lcddata2.A = GETBIT(temp, 0);
    _lcddata2.F = GETBIT(temp, 1);
    _lcddata2.m = GETBIT(temp, 2);
    _lcddata2.u = GETBIT(temp, 3);
    _lcddata2.n = GETBIT(temp, 4);
//    _lcddata2.speaker = GETBIT(temp, 5);
//    _lcddata2.diode = GETBIT(temp, 6);
//    _lcddata2.low_battery = GETBIT(temp, 7);
    
    //4 Data29
    temp = *pdata++;
    _lcddata2.percent = GETBIT(temp, 0);
    _lcddata2.Hz = GETBIT(temp, 1);
    _lcddata2.res = GETBIT(temp, 2);
    _lcddata2.M = GETBIT(temp, 3);
    _lcddata2.k = GETBIT(temp, 4);
    _lcddata2.V = GETBIT(temp, 5);
    _lcddata2.ac = GETBIT(temp, 6);
    _lcddata2.dc = GETBIT(temp, 7);
    
    //5 Data30
    temp = *pdata++;
//    _lcddata2.H__ = GETBIT(temp, 0);
    _lcddata2.Wh = GETBIT(temp, 1);
    _lcddata2.VAr = GETBIT(temp, 2);
    _lcddata2.VA = GETBIT(temp, 3);
    _lcddata2.F0 = GETBIT(temp, 4);
    _lcddata2.C0 = GETBIT(temp, 5);
//    _lcddata2.H__F = GETBIT(temp, 6);
//    _lcddata2.H__R = GETBIT(temp, 7);
    
}

- (void)parseButtonData:(NSData *)data {
    Byte byte = ((char *)data.bytes)[0];
    _buttonState = byte;
}

- (void)parseDialData:(NSData *)data {
    Byte byte = ((char *)data.bytes)[0];
    _dialState = byte;
    
//    NSLog(@"dial: 0x%02x", byte);
}

#pragma mark - Public methods
- (BOOL)isDataValid:(unsigned char*)bytes {
#if !TARGET_IPHONE_SIMULATOR
    // Wind 版本2的长度为32，即0x20
    if (bytes[0] != 0x55 || bytes[1] != 0x20) {
        return NO;
    }
    unsigned char crc8 = CRC8_Table(bytes, 0x1F);
    if (crc8 != bytes[0x1F])
        return NO;
    return YES;
#else
    return YES;
#endif
}

- (BOOL)trimInvalidData:(NSMutableData *)data {
    unsigned char *bytes=(unsigned char*)[data bytes];
    int length = (int)data.length;
    // Wind 版本2长度为32
    if (length < 0x20) return NO;
    
    int i = 0;
    for (i = 0; i <= length - 0x20; i++) {
        if ([self isDataValid:bytes+i])
            break;
    }
    if (i > length - 0x20) {
        return NO;
    }
    if (i > 0) {
        [data replaceBytesInRange:NSMakeRange(0, i) withBytes:NULL length:0];
    }
    return YES;
}

// Wind 解析数据
//0   1  2   3   4   5   6
//55 20  02  77  22  25   01
//
//7   8
//26 ff
//
//9   10   11   12  13   14  15   16   17  18
//00  00   00   01  40   02  00   00   00  00
//
//19   20   21   22  23   24
//fe   ff   00   00  00   00
//
//25   26  27  28  29  30
//fe   ff  00  00  00  00
//
//31
//28
- (int)parseWithData:(NSData *)data {
//    VTLog(@"Log data: %@", data);
    int length= (int)data.length;
    unsigned char *test=(unsigned char *)[data bytes];
    NSMutableData *auxData = nil;
    
    //新包有效,屏蔽缓冲区中的老包
    if (length >= 0x20) {
        if ([self isDataValid:test]) {
            [_bufferData replaceBytesInRange:NSMakeRange(0, _bufferData.length) withBytes:NULL length:0];
            [_bufferData setLength:0];
        }
    }
    
    [_bufferData appendData:data];
    if (![self trimInvalidData:_bufferData]) {
        return NO;
    }
    auxData = [NSMutableData dataWithBytes:_bufferData.bytes length:0x20];
    [_bufferData replaceBytesInRange:NSMakeRange(0, 0x20) withBytes:NULL length:0];
    // Wind 实际数据
    test = (unsigned char*)auxData.bytes;
    NSLog(@"Wind 一个完整数据:%@",auxData);
    
    
    // Wind 产品型号
    _deviceModel = (test[4]<<8)+test[5];
    NSLog(@"Wind 产品型号：%lx",_deviceModel);
    _adapter = [VTDeviceMgr adapterForModel:_deviceModel];
    _adapter.parser = self;
    
    // Wind 主LCD数据 第9位到第18位 共10位
    Byte tempData[16] = {0};
    for(int i = 0; i < 10; i++)
        tempData[i] = test[i+9];
    NSData *lcdData = [NSData dataWithBytes:tempData length:10];
    NSLog(@"Wind LCD Data:%@",lcdData);
    [self parseLCDData:lcdData];
    
    // Wind 副一LCD数据 第19位到24位 共6位
    Byte tempData1[16] = {0};
    for(int i = 0; i < 6; i++)
        tempData1[i] = test[i+19];
    NSData *lcdData1 = [NSData dataWithBytes:tempData1 length:6];
    NSLog(@"Wind 副一LCD Data:%@",lcdData1);
    [self parseLCDData1:lcdData1];
    
    // Wind 副二LCD数据 第25位到30位 共6位
    Byte tempData2[16] = {0};
    for(int i = 0; i < 6; i++)
        tempData2[i] = test[i+25];
    NSData *lcdData2 = [NSData dataWithBytes:tempData2 length:6];
    NSLog(@"Wind 副二LCD Data:%@",lcdData2);
    [self parseLCDData2:lcdData2];
    
    // Wind 按键信息 第8位
    NSData *buttonData = [NSData dataWithBytes:&test[8] length:1];
    [self parseButtonData:buttonData];
    // Wind 播盘信息 第7位
    NSData *dialData = [NSData dataWithBytes:&test[7] length:1];
    [self parseDialData:dialData];
    
#warning 该方法未知作用
    if (_adapter && [_adapter respondsToSelector:@selector(afterParse)]) {
        [_adapter afterParse];
    }

    return YES;
}

// 返回lcd显示数据
- (NSString *)lcdString {
    return [self parseLcdLabelNumber:&_lcddata.number isNcv:_lcddata.ncv_non_contact_voltage_detection];
}

// 返回实际数值
- (float)floatValue {
    if (_lcddata.overload) {
        return 0;
    }
    return [self parseNumber:&_lcddata.number];
}

// 返回单位数据
- (NSString *)unitString {
    return [self parseSegUnit:&_lcddata];
}

// 返回功能数据
- (NSString *)funcString {
    return [self parseSegFunction:&_lcddata];
}

// 解析后的数据,用来画表格或曲线
- (NSDictionary *)analyzedDict {
    // 时间和时差
    static NSDate *lastDate = nil;
    NSDate *date = [NSDate date];
    NSTimeInterval interval = 0;
    if (lastDate) {
        interval = [date timeIntervalSinceDate:lastDate]*1000;
    }
    lastDate = date;
    
    float value = self.floatValue;
    NSString *unitString = self.unitString;
    NSString *deviceModel = self.deviceModelName;
    
    // 添加辅助字段,判断是否是overload
    return @{
             @"time":date,
             @"value":@(value),
             @"unit":unitString,
             @"model":deviceModel,
             @"interval":@(interval),
             @"overload": @(_lcddata.overload),
             };
}


- (CGFloat)angle {
    if (_adapter) {
        return [_adapter angle];
    }
    return 0;
}

- (NSInteger)pointPos {
    if (_adapter) {
        return [_adapter pointPos];
    }
    return 0;
}

- (BOOL)isMax {
    return _lcddata.max;
}

- (BOOL)isMin {
    return _lcddata.min;
}

- (BOOL)isH {
    return _lcddata.hold;
}

- (BOOL)isBlue {
    return _lcddata.ble;
}

- (BOOL)isHZ {
    return _lcddata.Hz;
}

- (BOOL)isLowBattery {
    return _lcddata.low_battery;
}

- (BOOL)isDrawable {
//    if (_lcddata.ncv_non_contact_voltage_detection) {
//        return NO;
//    }
    return YES;
}

- (BOOL)isFuncClick {
    if (_adapter && [_adapter respondsToSelector:_cmd]) {
        return [_adapter isFuncClick];
    }
    return (_buttonState==0x07);
}

- (BOOL)isRangeClick {
    if (_adapter && [_adapter respondsToSelector:_cmd]) {
        return [_adapter isRangeClick];
    }
    return (_buttonState==0x02);
}

- (BOOL)isRELClick {
    if (_adapter && [_adapter respondsToSelector:_cmd]) {
        return [_adapter isRELClick];
    }
    return (_buttonState==0x04);
}

- (BOOL)isHoldClick {
    if (_adapter && [_adapter respondsToSelector:_cmd]) {
        return [_adapter isHoldClick];
    }
    return (_buttonState==0x08);
}

- (BOOL)isHZClick {
    if (_adapter && [_adapter respondsToSelector:_cmd]) {
        return [_adapter isHZClick];
    }
    return (_buttonState==0x0f || _buttonState==0x10 || _buttonState==0x30);
}

- (BOOL)isBrightClick {
    if (_adapter && [_adapter respondsToSelector:_cmd]) {
        return [_adapter isBrightClick];
    }
    return (_buttonState==0x0e || _buttonState==0x0d);
}

// 返回拔盘类型
- (NSInteger)dialType {
    return _dialState;
}

- (NSString *)deviceModelName {
    if (_adapter) {
        return [_adapter modelName];
    }
    return @"";
}

// 简单地返回量程信息
- (NSDictionary *)getRange {
    if (_adapter && [_adapter respondsToSelector:_cmd]) {
        return [_adapter getRange];
    }
    
    NSInteger max = 0, min = 0;
    
    if (_lcddata.V) {
        if (_lcddata.m) {
            max = 600;
        } else {
            max = 600;
        }
        min = -max;
    } else if (_lcddata.A) {
        if (_lcddata.m) {
            max = 600;
        } else if (_lcddata.u) {
            max = 600;
        } else {
            max = 10;
        }
        min = -max;
    } else if (_lcddata.res) {
        if (_lcddata.M) {
            max = 60;
        } else if (_lcddata.k) {
            max = 600;
        } else {
            max = 600;
        }
        min = 0;
    } else if (_lcddata.F) {
        max = 100; min = 0;
    } else if (_lcddata.F0) {
        max = 1000; min = -20;
    } else if (_lcddata.C0) {
        max = 1832; min = -4;
    } else if (_lcddata.Hz) {
        max = 10; min = 0;
    } else if (_lcddata.hFE) {
        max = 10; min = 0;
    }
    return @{@"min": @(min), @"max": @(max)};
}

// 返回拔盘描述信息
- (NSString *)dialString {
    return [NSString stringWithFormat:@"dial:0x%02x", _dialState];
}

- (NSString *)simpleDialString {
    return [NSString stringWithFormat:@"dial:0x%02x", _dialState];
}

- (NSInteger)deviceModel {
    return _deviceModel;
}

// 转成speech可以识别的字串
- (NSString *)convertToSpeechText {
    NSString *toSay = nil;
    
    // 特殊处理的情况,ncv
    if (_lcddata.ncv_non_contact_voltage_detection) {
        NSString *lcd = self.lcdString;
        if ([lcd isEqualToString:@"EF"]) {
            return @"EF";
        }
        return [self.class trimData:self.lcdString];
    }
    
    // overload
    if ([self.lcdString isEqualToString:@"0.L"]) {
        toSay = @"Overload";
        return toSay;
    }
    
    toSay = [NSString stringWithFormat:@"%@ %@", [self.class trimData:self.lcdString], [self.class unitSpeech:self.unitString]];
    
    return toSay;
}

// 只返回简单的类型,供文件中查看
+ (NSString *)simpleDialStringWithType:(NSInteger)dialType {
    return @"";
}

// 去除多余的0
+ (NSString *)trimData:(NSString *)text {
    // 整数部分,和小数部分
    NSInteger intValue=0, floatValue=0;
    BOOL isPositive=YES;
    
    NSRange range = [text rangeOfString:@"-"];
    if (range.location == 0) {
        isPositive = NO;
        text = [text substringFromIndex:1];
    }
    
    NSArray *cps = [text componentsSeparatedByString:@"."];
    if (cps.count>=2) {
        intValue = atoi([cps[0] UTF8String]);
        floatValue = atoi([cps[1] UTF8String]);
    } else {
        intValue = atoi([text UTF8String]);
    }
    NSString *res = nil;
    if (floatValue != 0.0) {
        res = [NSString stringWithFormat:@"%@.%@", @(intValue), @(floatValue)];
    } else {
        res = [NSString stringWithFormat:@"%@", @(intValue)];
    }
    if (!isPositive) {
        res = [NSString stringWithFormat:@"-%@", res];
    }
//    NSLog(@"res:%@", res);
    return res;
}

// 读unit
+ (NSString *)unitSpeech:(NSString *)text {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Speech" ofType:@"plist"];
    NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:path];
    if (rootDict[text]) {
        return rootDict[text];
    }
    return text;
}

@end
