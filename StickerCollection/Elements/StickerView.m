//
//  StickerView.m
//  StickerCollection
//
//  Created by Alexander Gavrilko on 6/22/19.
//  Copyright © 2019 Alexander Gavrilko. All rights reserved.
//

#import "Defines.h"
#import "StickerView.h"

#define LAYER_ANIMATION(animation, ...) ({ \
    [CATransaction begin]; \
    [CATransaction setCompletionBlock:^{ __VA_ARGS__; }]; \
    animation; \
    [CATransaction commit]; \
})

static const CGFloat kLayerOpacity = 0.9f;
static const CGFloat kShadowOpacity = 0.2f;
static const CGSize kShadowOffset = (CGSize) { .width = 0.0f, .height = 8.0f };

@implementation StickerView

- (void)setBouncing:(BOOL)bouncing {
    if (bouncing == _bouncing) {
        return;
    }
    
    UPDATE_KVO_PROPERTY({
        
        _bouncing = bouncing;
        if (_bouncing) {
            
            const CFTimeInterval timeOffset = arc4random_uniform(10) * 0.1;
            [self.layer addAnimation:({
                
                CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
                animation.values = @[@(-0.02), @(0.02)];
                animation.autoreverses = YES;
                animation.duration = 0.15;
                animation.repeatCount = HUGE_VALF;
                animation.timeOffset = timeOffset;
                animation;
                
            }) forKey:@"bouncingZ"];
            [self.layer addAnimation:({
                
                CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
                animation.values = @[@(-1.0f), @(1.0)];
                animation.autoreverses = YES;
                animation.duration = 0.14;
                animation.repeatCount = HUGE_VALF;
                animation.timeOffset = timeOffset;
                animation;
                
            }) forKey:@"bouncingX"];
            [self.layer addAnimation:({
                
                CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
                animation.values = @[@(-1.0f), @(1.0)];
                animation.autoreverses = YES;
                animation.duration = 0.13;
                animation.repeatCount = HUGE_VALF;
                animation.timeOffset = timeOffset;
                animation;
                
            }) forKey:@"bouncingY"];
            
        } else {
            
            [self.layer removeAnimationForKey:@"bouncingZ"];
            [self.layer removeAnimationForKey:@"bouncingX"];
            [self.layer removeAnimationForKey:@"bouncingY"];
        }
        
    });
}

- (void)setSelected:(BOOL)selected {
    if (selected == _selected) {
        return;
    }
    
    UPDATE_KVO_PROPERTY({
        
        _selected = selected;
        if (_selected) {
            
            self.layer.zPosition = 1.0f;
            self.layer.opacity = kLayerOpacity;
            self.layer.shadowColor = UIColor.blackColor.CGColor;
            self.layer.shadowOpacity = kShadowOpacity;
            self.layer.shadowOffset = kShadowOffset;
            self.layer.shadowRadius = 3.2f;
            self.layer.masksToBounds = NO;
            
        } else {
            
            self.layer.opacity = 1.0f;
            self.layer.shadowOpacity = 0.0f;
            self.layer.shadowOffset = CGSizeZero;
            
            LAYER_ANIMATION({
                
                [self.layer addAnimation:({
                    
                    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                    animation.fromValue = @(kLayerOpacity);
                    animation.toValue = @(1.0f);
                    animation;
                    
                }) forKey:@"opacity"];
                [self.layer addAnimation:({
                    
                    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
                    animation.fromValue = @(kShadowOpacity);
                    animation.toValue = @(0.0f);
                    animation;
                    
                }) forKey:@"shadowOpacity"];
                [self.layer addAnimation:({
                    
                    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
                    animation.fromValue = @(kShadowOffset);
                    animation.toValue = @(CGSizeZero);
                    animation;
                    
                }) forKey:@"shadowOffset"];
                
            }, self.layer.zPosition = 0.0f; self.layer.masksToBounds = YES);

        }
        
    });
}

@end
