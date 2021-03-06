//
//  OutputFilterImageManager.m
//  OpenGLES
//
//  Created by zhaoguyixia on 2020/6/21.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import "OutputFilterImageManager.h"
#import "MFGLProgram.h"

@interface OutputFilterImageManager ()
{
    CGSize _size;
}
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint frameBuffer;
@property (nonatomic, assign) GLuint texture;
@property (nonatomic, strong) MFGLProgram *mfProgram;
@end

@implementation OutputFilterImageManager

- (instancetype)init{
    if (self = [super init]) {

        [self initContext];
        
        [self initFrameBuffer];
        
        [self initProgram];
        
    }
    return self;
}


- (void)initContext{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (self.context) {
        [EAGLContext setCurrentContext:self.context];
    }
}

- (void)initFrameBuffer{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
}

- (void)initProgram{
    NSString *vFile = [[NSBundle mainBundle] pathForResource:@"gray" ofType:@"vsh"];
    NSString *fFile = [[NSBundle mainBundle] pathForResource:@"gray" ofType:@"fsh"];
    self.mfProgram = [[MFGLProgram alloc] initWithVerFile:vFile fragFile:fFile];
    [self.mfProgram linkUseProgram];
}


- (void)setTextureSize:(CGSize)size{
    _size = CGSizeMake(size.width*2, size.height*2);
    [self generateTexture];
}
- (void)generateTexture{
    
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    // 载入纹理数据
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)_size.width, (int)_size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    //将纹理绑定到FBO
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture, 0);
    
    GLenum err = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (err != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"frame buffer error %u", err);
    }else{
        NSLog(@"frame buffer success");
    }
    // 不加，则glReadPixels读取不到数据
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (void)setImage:(UIImage *)image{
    
    // 加载纹理
    [self readTextureForImage:image];
    
}

// copy的代码
- (void)readTextureForImage:(UIImage *)image{
    
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
    // 将纹理绑定到指定的纹理ID上
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    // 设置纹理属性
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    
    // 载入纹理数据
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    GLenum err = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (err != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"frame buffer error %u", err);
    }else{
        NSLog(@"frame buffer success");
    }
    
    // 释放
    free(spriteData);
}

- (void)render{
    float width = _size.width;
    float height = _size.height;
    
    glViewport(0, 0, (int)width, (int)height);
    
    glClearColor(0.5, 0.5, 0.5, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    float sub = 1.0;
    
    GLfloat points[] = {
        -sub,  sub, 0,
        -sub, -sub, 0,
         sub, -sub, 0,
         sub,  sub, 0,
    };
    
    GLfloat textCoors[] = {
        0, 0,
        0, 1,
        1, 1,
        1, 0,
    };
    
    // 激活一个纹理，绑定
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    [self.mfProgram letSample:"colorMap" useTexture:1];
    
    [self.mfProgram useLocationAttribute:"position" perReadCount:3 points:points];
    
    [self.mfProgram useLocationAttribute:"vTextCoor" perReadCount:2 points:textCoors];
    
    // 绘图
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
}

- (UIImage *)getProcessImage{
    
    __block CGImageRef cgImageFromBytes;
    
    NSUInteger totalBytesForImage = (int)_size.width * (int)_size.height * 4;
    
    GLubyte *rawImagePixels;
    CGDataProviderRef dataProvider = NULL;
    
    rawImagePixels = (GLubyte *)malloc(totalBytesForImage);
    
    glReadPixels(0, 0, (int)_size.width, (int)_size.height, GL_RGBA, GL_UNSIGNED_BYTE, rawImagePixels);
    dataProvider = CGDataProviderCreateWithData(NULL, rawImagePixels, totalBytesForImage, NULL);
    
    CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();
    
    cgImageFromBytes = CGImageCreate((int)_size.width, (int)_size.height, 8, 32, 4 * (int)_size.width, defaultRGBColorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaLast, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(defaultRGBColorSpace);
    
    return [UIImage imageWithCGImage:cgImageFromBytes];
}

@end
