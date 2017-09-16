//
//  EMDragGestureRecognizer.h
//  AMHexin
//
//  Created by HeminWon on 2017/4/10.
//  Copyright © 2017年 AMHexin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMDragGestureRecognizer : UIGestureRecognizer

/**
 获得在指定视图上的位移
 
 @param view 计算位移的视图
 @return 返回位移
 */
- (CGPoint)hxTranslationInView:(nullable UIView *)view;

/**
 将某个视图上的位移设定为需要的值

 @param translation 位移的当前值
 @param view 视图
 */
- (void)setHXTranslation:(CGPoint)translation inView:(nullable UIView *)view;
@end
