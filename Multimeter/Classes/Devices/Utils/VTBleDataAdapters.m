//
//  VTBleDataAdapters.m
//  Multimeter
//
//  Created by Vincent on 27/09/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "VTBleDataAdapters.h"

@implementation VTBleDataAdapter_450B

@synthesize parser = _parser;

- (NSString *)modelName {
    return @"DDM450B";
}

#if !TARGET_IPHONE_SIMULATOR
- (NSInteger)pointPos {
    NSInteger dialState = _parser.dialType;
    
    // 电流通过单位来判断
    if (_parser->_lcddata.A) {
        if (_parser->_lcddata.m) {
            return 8;
        } else if (_parser->_lcddata.u) {
            return 7;
        } else {
            return 9;
        }
    }
    // 二级管
    if (_parser->_lcddata.diode || dialState == 0x18) {
        return 3;
    }
    
    if (dialState == 0x10) {
        // 1.5v
        return 6;
    } else if (dialState == 0x11) {
        // 9v
        return 5;
    } else if (dialState == 0x08) {
        // 电阻
        return 4;
    } else if (dialState == 0x0f) {
        // ncv
        return 2;
    } else if (dialState == 0x15) {
        // V
        return 1;
    }
    return 0;
}
#else
extern int g_state;
- (NSInteger)pointPos {
    return g_state;
}
#endif

- (CGFloat)angle {
    CGFloat unit = M_PI*(1/9.0);
    return [self pointPos]*unit;
}

- (NSDictionary *)getRange {
    CGFloat max = 0, min = 0;
    
    LCDSegment _lcddata = self.parser->_lcddata;
    NSInteger dialState = _parser.dialType;
    
    if (_lcddata.V) {
        if (_lcddata.m) {
            max = 1000;
        } else {
            max = 600;
        }
        if (_lcddata.dc) {
            min = -max;
        }
    } else if (_lcddata.A) {
        if (_lcddata.m) {
            max = 1000;
        } else if (_lcddata.u) {
            max = 1000;
        } else {
            max = 10;
        }
        if (_lcddata.dc) {
            min = -max;
        }
    } else if (_lcddata.res) {
        if (_lcddata.M) {
            max = 40;
        } else if (_lcddata.k) {
            max = 1000;
        } else {
            max = 1000;
        }
        min = 0;
    } else if (_lcddata.F) {
        max = 100; min = 0;
    } else if (_lcddata.C0) {
        max = 1000; min = -20;
    } else if (_lcddata.F0) {
        max = 1832; min = -4;
    } else if (_lcddata.Hz) {
        if (_lcddata.M) {
            max = 10;
        } else if (_lcddata.k) {
            max = 1000;
        } else {
            max = 1000;
        }
        min = 0;
    }
    if (_lcddata.diode) {
        max = 2.7; min = 0;
    }
    if (_lcddata.speaker) {
        max = 50; min = 0;
    }
    if (_lcddata.hFE) {
        max = 2000; min = 0;
    }
    if (dialState == 0x10) {
        // 1.5v
        max = 1.5; min = 0;
    } else if (dialState == 0x11) {
        // 9v
        max = 9; min = 0;
    }
    if (_lcddata.ncv_non_contact_voltage_detection) {
        max = 5; min = 0;
    }
    
    return @{@"min": @(min), @"max": @(max)};
}

@end


@implementation VTBleDataAdapter_453B

@synthesize parser = _parser;

- (NSString *)modelName {
    return @"DDM453B";
}

- (NSString *)segFunction {
    // 再次作兼容
    NSString *tempString;
    if (_parser.dialType == 0x10) {
        tempString = [NSString stringWithFormat:@"1.5V Battery"];
    } else if (_parser.dialType == 0x11) {
        tempString = [NSString stringWithFormat:@"9V Battery"];
    }
    return tempString;
}


- (NSInteger)pointPos {
    NSInteger dialState = _parser.dialType;

    // ncv档要兼容判断
    if (_parser->_lcddata.ncv_non_contact_voltage_detection) {
        return 2;
    }
    
    // 电流通过单位来判断
    if (_parser->_lcddata.A) {
        if (_parser->_lcddata.m) {
            return 8;
        } else if (_parser->_lcddata.u) {
            return 7;
        } else {
            return 9;
        }
    }
    if (dialState == 0x0d) {
        // 温度
        return 6;
    } else if (dialState == 0x07) {
        // hz
        return 5;
    } else if (dialState == 0x05) {
        // 电容
        return 4;
    } else if (dialState == 0x0a) {
        // 电阻
        return 3;
    } else if (dialState == 0x0f) {
        // ncv
        return 2;
    } else if (dialState == 0x15) {
        return 1;
    }
    return 0;
}

- (CGFloat)angle {
    CGFloat unit = M_PI*(1/9.0);
    return unit*[self pointPos];
}

- (NSDictionary *)getRange {
    CGFloat max = 0, min = 0;
    
    LCDSegment _lcddata = self.parser->_lcddata;
//    NSInteger dialState = _parser.dialType;
    
    if (_lcddata.V) {
        if (_lcddata.m) {
            max = 1000;
        } else {
            max = 600;
        }
        if (_lcddata.dc) {
            min = -max;
        }
    } else if (_lcddata.A) {
        if (_lcddata.m) {
            max = 1000;
        } else if (_lcddata.u) {
            max = 1000;
        } else {
            max = 10;
        }
        if (_lcddata.dc) {
            min = -max;
        }
    } else if (_lcddata.res) {
        if (_lcddata.M) {
            max = 60;
        } else if (_lcddata.k) {
            max = 1000;
        } else {
            max = 1000;
        }
        min = 0;
    } else if (_lcddata.F) {
        max = 100; min = 0;
    } else if (_lcddata.C0) {
        max = 1000; min = -20;
    } else if (_lcddata.F0) {
        max = 1832; min = -4;
    } else if (_lcddata.Hz) {
        if (_lcddata.M) {
            max = 10;
        } else if (_lcddata.k) {
            max = 1000;
        } else {
            max = 1000;
        }
        min = 0;
    }
    if (_lcddata.diode) {
        max = 2.7; min = 0;
    }
    if (_lcddata.percent) {
        max = 100; min = 0;
    }
    if (_lcddata.speaker) {
        max = 50; min = 0;
    }
    if (_lcddata.hFE) {
        max = 2000; min = 0;
    }
    if (_lcddata.ncv_non_contact_voltage_detection) {
        max = 5; min = 0;
    }
    
    return @{@"min": @(min), @"max": @(max)};
}

@end


@implementation VTBleDataAdapter_C052

@synthesize parser = _parser;


- (NSString *)modelName {
    return @"DDMC052";
}

- (NSInteger)pointPos {
    NSInteger dialState = _parser.dialType;
    NSInteger res = 0;
    
    switch (dialState) {
        case 0x1A:
            res = 9;
            break;
        case 0x19:
            res = 8;
            break;
        case 0x18:
            res = 7;
            break;
        case 0x12:
            res = 6;
            break;
        case 0x07:
            res = 5;
            break;
        case 0x13:
            res = 4;
            break;
        case 0x0f:
            res = 3;
            break;
        case 0x01:
            res = 2;
            break;
        case 0x03:
            res = 1;
            break;
        default:
            break;
    }
    return res;
}

- (CGFloat)angle {
    CGFloat unit = M_PI*(1/9.0);
    return unit*[self pointPos];
}

- (NSDictionary *)getRange {
    CGFloat max = 0, min = 0;
    
    LCDSegment _lcddata = self.parser->_lcddata;
    NSInteger dialState = _parser.dialType;
    
    if (_lcddata.V) {
        if (_lcddata.m) {
            max = 1000;
        } else {
            max = 600;
        }
        if (_lcddata.dc) {
            min = -max;
        }
    } else if (_lcddata.A) {
        if (_lcddata.m) {
            max = 1000;
        } else if (_lcddata.u) {
            max = 1000;
        } else {
            max = 10;
        }
        if (_lcddata.dc) {
            min = -max;
        }
    } else if (_lcddata.res) {
        if (_lcddata.M) {
            max = 40;
        } else if (_lcddata.k) {
            max = 1000;
        } else {
            max = 1000;
        }
        min = 0;
    } else if (_lcddata.F) {
        max = 100; min = 0;
    } else if (_lcddata.C0) {
        max = 1000; min = -20;
    } else if (_lcddata.F0) {
        max = 1832; min = -4;
    } else if (_lcddata.Hz) {
        if (_lcddata.M) {
            max = 10;
        } else if (_lcddata.k) {
            max = 1000;
        } else {
            max = 1000;
        }
        min = 0;
    }
    if (_lcddata.diode) {
        max = 2.7; min = 0;
    }
    if (_lcddata.percent) {
        max = 100; min = 0;
    }
    if (_lcddata.speaker) {
        max = 50; min = 0;
    }
    if (_lcddata.hFE) {
        max = 2000; min = 0;
    }
    if (_lcddata.ncv_non_contact_voltage_detection) {
        max = 5; min = 0;
    }
    
    return @{@"min": @(min), @"max": @(max)};
}

// 对ncv作兼容
- (void)afterParse {
    if (self.pointPos == 3) {
        _parser->_lcddata.ncv_non_contact_voltage_detection = YES;
    }
}

- (BOOL)isHoldClick {
    Byte buttonState = _parser->_buttonState;
    return (buttonState==0x08 || buttonState==0x24);
}

@end

@implementation VTBleDataAdapter_8238

@synthesize parser = _parser;


- (NSString *)modelName {
    return @"DDM8238";
}

- (NSInteger)pointPos {
    NSInteger dialState = _parser.dialType;
    NSInteger res = 0;
    
    switch (dialState) {
        case 0x0f:
            res = 9;
            break;
        case 0x10:
            res = 8;
            break;
        case 0x11:
            res = 7;
            break;
        case 0x1a:
            res = 6;
            break;
        case 0x19:
            res = 5;
            break;
        case 0x18:
            res = 4;
            break;
        case 0x0a:
            res = 3;
            break;
        case 0x0b:
            res = 2;
            break;
        case 0x0c:
            res = 2;
            break;
        case 0x0d:
            res = 2;
            break;
        case 0x15:
            res = 1;
            break;
        default:
            break;
    }
    
    if (_parser->_lcddata.A) {
        if (_parser->_lcddata.m) {
            return 5;
        } else if (_parser->_lcddata.u) {
            return 4;
        } else {
            return 6;
        }
    }
    
    return res;
}

- (CGFloat)angle {
    CGFloat unit = M_PI*(1/9.0);
    return unit*[self pointPos];
}

- (NSDictionary *)getRange {
    CGFloat max = 0, min = 0;
    
    LCDSegment _lcddata = self.parser->_lcddata;
    NSInteger dialState = _parser.dialType;
    
    if (_lcddata.V) {
        if (_lcddata.m) {
            max = 1000;
        } else {
            max = 600;
        }
        if (_lcddata.dc) {
            min = -max;
        }
    } else if (_lcddata.A) {
        if (_lcddata.m) {
            max = 1000;
        } else if (_lcddata.u) {
            max = 1000;
        } else {
            max = 10;
        }
        if (_lcddata.dc) {
            min = -max;
        }
    } else if (_lcddata.res) {
        if (_lcddata.M) {
            max = 40;
        } else if (_lcddata.k) {
            max = 1000;
        } else {
            max = 1000;
        }
        min = 0;
    } else if (_lcddata.F) {
        max = 100; min = 0;
    } else if (_lcddata.C0) {
        max = 1000; min = -20;
    } else if (_lcddata.F0) {
        max = 1832; min = -4;
    } else if (_lcddata.Hz) {
        if (_lcddata.M) {
            max = 10;
        } else if (_lcddata.k) {
            max = 1000;
        } else {
            max = 1000;
        }
        min = 0;
    }
    if (_lcddata.diode) {
        max = 3; min = 0;
    }
    if (_lcddata.speaker) {
        max = 50; min = 0;
    }
    if (_lcddata.hFE) {
        max = 2000; min = 0;
    }
    if (dialState == 0x10) {
        // 1.5v
        max = 1.5; min = 0;
    } else if (dialState == 0x11) {
        // 9v
        max = 9; min = 0;
    }
    if (_lcddata.ncv_non_contact_voltage_detection) {
        max = 5; min = 0;
    }
    
    return @{@"min": @(min), @"max": @(max)};
}

- (BOOL)isFuncClick {
    Byte buttonState = _parser->_buttonState;
    return (buttonState==0x03);
}

- (BOOL)isHoldClick {
    Byte buttonState = _parser->_buttonState;
    return (buttonState==0x08 || buttonState==0x20);
}

- (BOOL)isRangeClick {
    Byte buttonState = _parser->_buttonState;
    return (buttonState==0x02);
}

@end

@implementation VTBleDataAdapter_2225A

@synthesize parser = _parser;

- (NSString *)modelName {
    return @"MS2225A";
}

//- (NSString *)segFunction {
//    // 再次作兼容
//    NSString *tempString;
//    if (_parser.dialType == 0x10) {
//        tempString = [NSString stringWithFormat:@"1.5V Battery"];
//    } else if (_parser.dialType == 0x11) {
//        tempString = [NSString stringWithFormat:@"9V Battery"];
//    }
//    return tempString;
//}

#if !TARGET_IPHONE_SIMULATOR
- (NSInteger)pointPos {
    NSInteger dialState = _parser.dialType;
    
//    // ncv档要兼容判断
//    if (_parser->_lcddata.ncv_non_contact_voltage_detection) {
//        return 2;
//    }
    
    // 电流通过单位来判断
    if (_parser->_lcddata.A) {
        if (_parser->_lcddata.m) {
            return 8;
        } else if (_parser->_lcddata.u) {
            return 7;
        } else {
            return 9;
        }
    }
    // 二级管
    if (_parser->_lcddata.diode || dialState == 0x18) {
        return 3;
    }
    
    if (dialState == 0x10) {
        // 1.5v
        return 6;
    } else if (dialState == 0x11) {
        // 9v
        return 5;
    } else if (dialState == 0x08) {
        // 电阻
        return 4;
    } else if (dialState == 0x0f) {
        // ncv
        return 2;
    } else if (dialState == 0x15) {
        // V
        return 1;
    }
    return 0;
}
#else
extern int g_state;
- (NSInteger)pointPos {
    return g_state;
}
#endif

- (CGFloat)angle {
    CGFloat unit = M_PI*(1/9.0);
    return [self pointPos]*unit;
}

- (NSDictionary *)getRange {
    CGFloat max = 0, min = 0;
    
    LCDSegment _lcddata = self.parser->_lcddata;
    NSInteger dialState = _parser.dialType;
    
    if (_lcddata.V) {
        if (_lcddata.m) {
            max = 1000;
        } else {
            max = 600;
        }
        if (_lcddata.dc) {
            min = -max;
        }
    } else if (_lcddata.A) {
        if (_lcddata.m) {
            max = 1000;
        } else if (_lcddata.u) {
            max = 1000;
        } else {
            max = 10;
        }
        if (_lcddata.dc) {
            min = -max;
        }
    } else if (_lcddata.res) {
        if (_lcddata.M) {
            max = 40;
        } else if (_lcddata.k) {
            max = 1000;
        } else {
            max = 1000;
        }
        min = 0;
    } else if (_lcddata.F) {
        max = 100; min = 0;
    } else if (_lcddata.C0) {
        max = 1000; min = -20;
    } else if (_lcddata.F0) {
        max = 1832; min = -4;
    } else if (_lcddata.Hz) {
        if (_lcddata.M) {
            max = 10;
        } else if (_lcddata.k) {
            max = 1000;
        } else {
            max = 1000;
        }
        min = 0;
    }
    if (_lcddata.diode) {
        max = 2.7; min = 0;
    }
    if (_lcddata.speaker) {
        max = 50; min = 0;
    }
    if (_lcddata.hFE) {
        max = 2000; min = 0;
    }
    if (dialState == 0x10) {
        // 1.5v
        max = 1.5; min = 0;
    } else if (dialState == 0x11) {
        // 9v
        max = 9; min = 0;
    }
    if (_lcddata.ncv_non_contact_voltage_detection) {
        max = 5; min = 0;
    }
    
    return @{@"min": @(min), @"max": @(max)};
}

@end

