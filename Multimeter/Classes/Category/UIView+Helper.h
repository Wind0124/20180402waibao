//
//  UIView+Helper.h
//
//  Created by vincent on 13/11/12.
//  Copyright (c) 2013 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>

// 重定义,适配横屏
//#ifdef SCREENHEIGHT
//#undef SCREENHEIGHT
#define SCREENHEIGHT ([UIView screenSize].height)
//#endif

//#ifdef SCREENWIDTH
//#undef SCREENWIDTH
#define SCREENWIDTH ([UIView screenSize].width)
//#endif

#ifdef k2PROPOR
#undef k2PROPOR
#endif
#define k2PROPOR ([UIView screenSize].width/375.0)

#ifdef k3PROPOR
#undef k3PROPOR
#endif
#define k3PROPOR ([UIView screenSize].width/414.0)

#ifdef AUTO_2PX
#undef AUTO_2PX
#endif
#define AUTO_2PX(x) ((x)/2.0*k2PROPOR)

#ifdef AUTO_3PX
#undef AUTO_3PX
#endif
#define AUTO_3PX(x) ((x)/3.0*k3PROPOR)


//#define AUTO_PX(w) (((float)(w))/2.0f * KPROPOR)

@interface UIView (Helper)

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

@property (nonatomic) CGFloat leftEx;
@property (nonatomic) CGFloat topEx;
@property (nonatomic) CGFloat rightEx;
@property (nonatomic) CGFloat bottomEx;

- (BOOL)containsSubView:(UIView *)subView;
//- (BOOL)containsSubViewOfClassType:(Class)class;
- (void)removeAllSubViews;
// 修改视图层级,把srcView从superView中移到dstView中.
+ (void)moveView:(UIView *)srcView toView:(UIView *)dstView withSameContraint:(BOOL)yesOrNO;
// 填充的mask
+ (UIViewAutoresizing)fillAutoresizingMask;

// 固定的屏幕宽高
+ (CGSize)screenSize;
// 旋转屏后的屏幕宽高
+ (CGSize)screenSizeEx;
// 当前界面是否是横屏(注意不是设备的朝向)
+ (BOOL)isLanscape;

// 去除view和它的一级subview的约束
- (void)clearSubviewContraints;

@end
