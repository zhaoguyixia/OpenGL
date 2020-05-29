//
//  GLSLUtils.m
//  OpenGLES集合
//
//  Created by 李明锋 on 2020/4/4.
//  Copyright © 2020 limingfeng. All rights reserved.
//

#import "GLSLUtils.h"

@implementation GLSLUtils

+ (GLuint)loadShaderProgramFrom:(NSString *)verFile fragFile:(NSString *)fragFile{
    
    GLuint verShader, fragShader;
    
    GLuint program = glCreateProgram();
    
    [GLSLUtils compileShader:&verShader type:GL_VERTEX_SHADER file:verFile];
    [GLSLUtils compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragFile];
    
    // 链接
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    // 释放
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}

+ (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)filePath{
    
    // 读取文件中的字符串
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    
    // 创建shader
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    
    glCompileShader(*shader);
}

+ (void)readTexture:(NSString *)imgName{
    // 判断是哪里的图片，目前先认为是asset中的
    [GLSLUtils readTextureForImage:[UIImage imageNamed:imgName]];
}

+ (void)readTextureForImage:(UIImage *)image{
    
    // 1.将UIimage转成 CGImageRef
    CGImageRef spriteImage = image.CGImage;
    if (!spriteImage) {
        NSLog(@"fail load image %@", image);
        exit(1);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    // 获取图片字节数 宽 x 高 x 4 (RGBA)
    GLubyte *spriteData = (GLubyte *)calloc(width*height*4, sizeof(GLubyte));
    
    // 创建上下文
    /*
    参数1：data,指向要渲染的绘制图像的内存地址
    参数2：width,bitmap的宽度，单位为像素
    参数3：height,bitmap的高度，单位为像素
    参数4：bitPerComponent,内存中像素的每个组件的位数，比如32位RGBA，就设置为8
    参数5：bytesPerRow,bitmap的每一行的内存所占的比特数
    参数6：colorSpace,bitmap上使用的颜色空间  kCGImageAlphaPremultipliedLast：RGBA
    */
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 在CGContextRef 上将图片绘制出来
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(spriteContext, rect, spriteImage);
    CGContextRelease(spriteContext);
    // 将纹理绑定到默认的纹理ID上
    glBindTexture(GL_TEXTURE_2D, 0);
    
    // 设置纹理属性
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    
    // 载入纹理数据
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    // 释放
    free(spriteData);
}

@end
