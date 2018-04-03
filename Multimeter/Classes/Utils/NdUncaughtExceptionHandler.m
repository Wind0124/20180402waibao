//
//  NdUncaughtExceptionHandler.m
//
//  Created by vincent on 15/10/15.
//  Copyright © 2015年 vincent. All rights reserved.
//

#import "NdUncaughtExceptionHandler.h"

NSString* applicationDocumentsDirectory()
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

void UncaughtExceptionHandler(NSException* exception)
{

    NSArray* arr = [exception callStackSymbols];
    NSString* reason = [exception reason];
    NSString* name = [exception name];
    NSString* url = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@", name, reason, [arr componentsJoinedByString:@"\n"]];
    NSString* path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
    [url writeToFile:path
          atomically:YES
            encoding:NSUTF8StringEncoding
               error:nil];

    NSString* urlStr = [NSString stringWithFormat:@"mailto:develop@xxx.com?subject=华仪表盘bug报告&body=很抱歉应用出现故障,感谢您的配合!发送这封邮件可协助我们改善此应用<br>"
                                                   "错误详情:<br>%@<br>--------------------------<br>%@<br>---------------------<br>%@",
                                                  name, reason, [arr componentsJoinedByString:@"<br>"]];

    NSLog(@"url is %@--%@--%@--%@", urlStr, reason, name, path);

    NSLog(@"exception elements is %@----%@---%@", reason, name, path);

    NSURL* url2 = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url2];
}

@implementation NdUncaughtExceptionHandler

- (NSString*)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (void)setDefaultHandler
{
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}

+ (NSUncaughtExceptionHandler*)getHandler
{
    return NSGetUncaughtExceptionHandler();
}

+ (void)TakeException:(NSException*)exception
{
    NSArray* arr = [exception callStackSymbols];
    NSString* reason = [exception reason];
    NSString* name = [exception name];
    NSString* url = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@", name, reason, [arr componentsJoinedByString:@"\n"]];
    NSString* path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
    [url writeToFile:path
          atomically:YES
            encoding:NSUTF8StringEncoding
               error:nil];
}

@end
