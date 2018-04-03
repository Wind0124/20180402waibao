//
//  UIImage+tintColor.m
//  Multimeter
//
//  Created by Vincent on 07/10/2016.
//  Copyright © 2016 vincent. All rights reserved.
//

#import "UIImage+tintColor.h"

@implementation UIImage (tintColor)

- (UIImage *)imageWithTintColor:(UIColor *)tintColor {
    return [self imageWithTintColor:tintColor blendMode:kCGBlendModeDestinationIn];
}

- (UIImage *)imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode {
    CGSize size = self.size;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size,
                                           NO,                     // Opaque
                                           self.scale);             // Use image scale
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [tintColor CGColor]);
    CGContextFillRect(context, rect);
    [self drawInRect:rect blendMode:blendMode alpha:1.0];
    
    UIImage *filledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return filledImage;
}

@end
