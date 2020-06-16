//
//  VideoDirector.h
//  OpenGLES
//
//  Created by wantexe on 2020/5/29.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoDirector : NSObject

+ (VideoDirector *)videoDirector;

- (void)setTextureSize:(CGSize)size;

/// 设置图片
/// @param image 图片数据
- (void)setImage:(UIImage *)image;

- (void)render;

/// 取处理后的图片
- (UIImage *)getProcessImage;

- (void)bindView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
