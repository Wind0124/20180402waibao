//
//  NdUncaughtExceptionHandler.h
//  
//  Created by vincent on 15/10/15.
//  Copyright © 2015年 vincent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NdUncaughtExceptionHandler : NSObject

+ (void)setDefaultHandler;
+ (NSUncaughtExceptionHandler *)getHandler;
+ (void)TakeException:(NSException *) exception;

@end
