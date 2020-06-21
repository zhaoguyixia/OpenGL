//
//  OutputFilterImageManager.h
//  OpenGLES
//
//  Created by zhaoguyixia on 2020/6/21.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OutputFilterImageManager : NSObject

- (void)setTextureSize:(CGSize)size;

/// 设置图片
/// @param image 图片数据
- (void)setImage:(UIImage *)image;

- (void)render;

/// 取处理后的图片
- (UIImage *)getProcessImage;

@end

NS_ASSUME_NONNULL_END
