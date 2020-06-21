//
//  GLSLUtils.h
//  OpenGLES集合
//
//  Created by zhaoguyixia on 2020/4/4.
//  Copyright © 2020 limingfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLSLUtils : NSObject

/// 通过顶点着色器和片元着色器文件编译成可用程序
/// @param verFile 顶点着色器路径
/// @param fragFile 片元着色器路径
+ (GLuint)loadShaderProgramFrom:(NSString *)verFile fragFile:(NSString *)fragFile;

/// 将图片数据读到显存中，然后通过片元着色器程序中的内建函数texture2D取出来对应点的颜色值
/// @param imgName 图片名
+ (void)readTexture:(NSString *)imgName;

+ (void)readTextureForImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
