//
//  MFGLProgram.h
//  OpenGLES
//
//  Created by zhaoguyixia on 2020/5/29.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLSLUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface MFGLProgram : NSObject
{
    GLfloat *points;
}
/// 初始化program
/// @param verFile 顶点着色器文件
/// @param fragFile 片元着色器文件
- (instancetype)initWithVerFile:(NSString *)verFile fragFile:(NSString *)fragFile;

- (void)linkUseProgram;

- (void)useDefaultSample:(GLchar *)colorMapKey;

- (void)letSample:(GLchar *)colorMapKey useTexture:(GLint)textureId;

/**
 * @abstract 给着色器里面的attribute属性赋值，一般是顶点数据和纹理坐标
 *
 * @param attributeKey 属性名
 * @param perCount 每次读取长度
 * @param points 需要读取的数组
 *
 */
- (void)useLocationAttribute:(GLchar *)attributeKey
                perReadCount:(GLint)perCount
                      points:(GLfloat *)points;



@end

NS_ASSUME_NONNULL_END
