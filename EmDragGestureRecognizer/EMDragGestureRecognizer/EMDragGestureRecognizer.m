//
//  EMDragGestureRecognizer.m
//  AMHexin
//
//  Created by HeminWon on 2017/4/10.
//  Copyright © 2017年 AMHexin. All rights reserved.
//

#import "EMDragGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface EMDragGestureRecognizer ()
@property (nonatomic) CGFloat minimumMovement;
@property (nonatomic,strong) NSValue *lastPointValueInWindow;//处理最后一个点
@property (nonatomic,strong) NSValue *currentPointValueInWindow;//当前的点
@property (nonatomic,strong) UITouch *currentTouch;
@property (nonatomic,strong) NSValue *beganPointValueInWindow;
@end

@implementation EMDragGestureRecognizer

#pragma mark - init
- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
    if (self) {
        self.minimumMovement = 5.0f;
    }
    return self;
}

- (void)reset {
    [super reset];
    self.lastPointValueInWindow = [NSValue valueWithCGPoint:CGPointZero];
    self.currentPointValueInWindow = [NSValue valueWithCGPoint:CGPointZero];
    self.beganPointValueInWindow = [NSValue valueWithCGPoint:CGPointZero];
}

#pragma mark - Events
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (touches.count != 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    self.currentTouch = [touches anyObject];
    CGPoint lastPoint = [self.currentTouch locationInView:[[UIApplication sharedApplication]keyWindow]];
    self.lastPointValueInWindow = [NSValue valueWithCGPoint:lastPoint];
    CGPoint currentPointInWindow = [[touches anyObject] locationInView:[[UIApplication sharedApplication]keyWindow]] ;
    self.currentPointValueInWindow = [NSValue valueWithCGPoint:currentPointInWindow];
    self.beganPointValueInWindow = [NSValue valueWithCGPoint:currentPointInWindow];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if (touches.count != 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    UITouch *touch = [touches anyObject];
    if(![touch isEqual:self.currentTouch]){
        //如果不是目前的点了，那就不做响应
        self.state = UIGestureRecognizerStateCancelled;
        return;
    }
    CGPoint nowPoint = [touch locationInView:self.view.window];
    CGPoint prePoint = [self.beganPointValueInWindow CGPointValue];
    CGFloat distance = sqrt(pow(fabsl(nowPoint.x - prePoint.x), 2.0) + pow(fabsl(nowPoint.y - prePoint.y), 2.0));
    if (distance > self.minimumMovement) {
        if (self.state == UIGestureRecognizerStatePossible) {
            self.state = UIGestureRecognizerStateBegan;
        } else {
            self.state = UIGestureRecognizerStateChanged;
        }
    }else{
        if (self.state == UIGestureRecognizerStateBegan) {
            self.state = UIGestureRecognizerStateChanged;
        }
    }
    CGPoint currentPointInWindow = [touch locationInView:[[UIApplication sharedApplication]keyWindow]] ;
    self.currentPointValueInWindow = [NSValue valueWithCGPoint:currentPointInWindow];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (touches.count != 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    if (self.state == UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateRecognized;
    }
    if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
        self.state = UIGestureRecognizerStateEnded;
        CGPoint currentPointInWindow = [[touches anyObject] locationInView:[[UIApplication sharedApplication]keyWindow]] ;
        self.currentPointValueInWindow = [NSValue valueWithCGPoint:currentPointInWindow];
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
        self.state = UIGestureRecognizerStateCancelled;
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

#pragma mark - Public
- (CGPoint)hxTranslationInView:(UIView *)view{
    CGPoint lastLocationPoint = [[self keyWindow]convertPoint:[self.lastPointValueInWindow CGPointValue] toView:view];
    CGPoint currentPoint = [[self keyWindow]convertPoint:[self.currentPointValueInWindow CGPointValue] toView:view];
    CGPoint offset = CGPointMake(currentPoint.x - lastLocationPoint.x, currentPoint.y - lastLocationPoint.y);
    return offset;
}

- (void)setHXTranslation:(CGPoint)translation inView:(nullable UIView *)view{
    CGPoint currentPoint = [[self keyWindow]convertPoint:[self.currentPointValueInWindow CGPointValue] toView:view];
    CGPoint relatedPoint = CGPointMake(currentPoint.x - translation.x, currentPoint.y - translation.y);
    CGPoint relatedPointInWindow = [view convertPoint:relatedPoint toView:[self keyWindow]];
    self.lastPointValueInWindow = [NSValue valueWithCGPoint:relatedPointInWindow];
}

#pragma mark - setter & getter
- (UIWindow *)keyWindow{
    return [[UIApplication sharedApplication]keyWindow];
}

@end
