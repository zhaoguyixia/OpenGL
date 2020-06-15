//
//  VideoDirector.m
//  OpenGLES
//
//  Created by wantexe on 2020/5/29.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import "VideoDirector.h"
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>
#import "MFGLProgram.h"

static VideoDirector *_videoDirector;

@interface VideoDirector ()
{
    CVPixelBufferRef renderTarget;
    CGSize _size;
    int readLockCount;
    CVOpenGLESTextureCacheRef _coreVideoTextureCache;
    CVOpenGLESTextureRef renderTexture;
}
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint frameBuffer;
@property (nonatomic, assign) GLuint texture;
@property (nonatomic, strong) MFGLProgram *mfProgram;
@property (nonatomic, strong) CAEAGLLayer *mfLayer;
@property (nonatomic, assign) GLuint renderBuffer;
@end

@implementation VideoDirector

+ (VideoDirector *)videoDirector{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _videoDirector = [[VideoDirector alloc] init];
    });
    return _videoDirector;
}

- (instancetype)init{
    if (self = [super init]) {
        readLockCount = 0;
        
        [self initLayer];
        
        [self initContext];
        
        [self initFrameBuffer];
        
//        [self initRenderBuffer];
        
        [self generateTexture];
        
        [self initProgram];
        
    }
    return self;
}

- (void)initLayer{
    self.mfLayer = [CAEAGLLayer layer];
    
    self.mfLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:@false, kEAGLDrawablePropertyRetainedBacking, kEAGLDrawablePropertyColorFormat, kEAGLColorFormatRGBA8, nil];
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

- (void)generateTexture{
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
//    glGenBuffers(1, &_texture);
//    glBindBuffer(GL_PIXEL_PACK_BUFFER, _texture);
    
    // 载入纹理数据
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 588, 640, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    //将纹理绑定到FBO
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture, 0);
    
    GLenum err = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (err != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"frame buffer error");
    }else{
        NSLog(@"frame buffer success");
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)initRenderBuffer{
    glDeleteRenderbuffers(1, &_renderBuffer);
    _renderBuffer = 0;
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
}

- (void)initProgram{
    NSString *vFile = [[NSBundle mainBundle] pathForResource:@"split" ofType:@"vsh"];
    NSString *fFile = [[NSBundle mainBundle] pathForResource:@"split" ofType:@"fsh"];
    self.mfProgram = [[MFGLProgram alloc] initWithVerFile:vFile fragFile:fFile];
    [self.mfProgram linkUseProgram];
}

- (void)bindView:(UIView *)view{
    self.mfLayer.frame = view.bounds;
//    [view.layer addSublayer:self.mfLayer];
    
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.mfLayer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _frameBuffer);
    
    GLenum err = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (err != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"frame buffer error");
    }else{
        NSLog(@"frame buffer success");
    }
}

- (void)setImage:(UIImage *)image{
    _size = image.size;
    
    float width = image.size.width;
    float height = image.size.height;
    
    glViewport(0, 0, (int)width, (int)height);
    
    glClearColor(0.5, 0.5, 0.5, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    float sub = 1.0;
    GLfloat points[] = {
        -sub, -sub, 0,
         sub, -sub, 0,
         sub,  sub, 0,
        -sub,  sub, 0,
    };
    
    GLfloat textCoors[] = {
        0, 0,
        1, 0,
        1, 1,
        0, 1,
    };
    
    [self.mfProgram useLocationAttribute:"position" perReadCount:3 points:points];
    
    [self.mfProgram useLocationAttribute:"vTextCoor" perReadCount:2 points:textCoors];
    
    // 加载纹理
    [self readTextureForImage:image];
    
    
    GLenum err = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    // GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT
    NSLog(@"frame buffer status %u", err);
    if (err != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"frame buffer error");
    }else{
        NSLog(@"frame buffer success");
    }
    
    
    [self.mfProgram clearColorMap:"colorMap"];
    
    // 绘图
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    if (self.mfLayer) {
//        [self.context presentRenderbuffer:GL_RENDERBUFFER];
    }
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
    // 将纹理绑定到默认的纹理ID上
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    
    // 设置纹理属性x
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

- (void)process{
    
    // By default, all framebuffers on iOS 5.0+ devices are backed by texture caches, using one shared cache
    if ([VideoDirector supportsFastTextureUpload])
    {
        CVOpenGLESTextureCacheRef coreVideoTextureCache = [self coreVideoTextureCache];
        // Code originally sourced from http://allmybrain.com/2011/12/08/rendering-to-a-texture-with-ios-5-texture-cache-api/
        
        CFDictionaryRef empty; // empty value for attr value.
        CFMutableDictionaryRef attrs;
        empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks); // our empty IOSurface properties dictionary
        attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
        
        CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, (int)_size.width, (int)_size.height, kCVPixelFormatType_32BGRA, attrs, &renderTarget);
        if (err)
        {
            NSLog(@"FBO size: %f, %f", _size.width, _size.height);
            NSAssert(NO, @"Error at CVPixelBufferCreate %d", err);
        }
        
        
//        err = CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault, coreVideoTextureCache, renderTarget,
//                                                            NULL, // texture attributes
//                                                            GL_TEXTURE_2D,
//                                                            GL_RGBA, // opengl format
//                                                            (int)_size.width,
//                                                            (int)_size.height,
//                                                            GL_RGBA, // native iOS format
//                                                            GL_UNSIGNED_BYTE,
//                                                            0,
//                                                            &renderTexture);
//        if (err)
//        {
//            NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
//        }
        
        CFRelease(attrs);
        CFRelease(empty);
        
        glBindTexture(CVOpenGLESTextureGetTarget(renderTexture), CVOpenGLESTextureGetName(renderTexture));
     
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(renderTexture), 0);

    }
   
    
//    #ifndef NS_BLOCK_ASSERTIONS
//    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
//    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
//    #endif
    
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (UIImage *)getProcessImage{
    
    
    __block CGImageRef cgImageFromBytes;
    
    NSUInteger totalBytesForImage = (int)_size.width * (int)_size.height * 4;
    
    GLubyte *rawImagePixels;
    CGDataProviderRef dataProvider = NULL;
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glViewport(0, 0, (int)_size.width, (int)_size.height);
    // 没有用
//    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    
    rawImagePixels = (GLubyte *)malloc(totalBytesForImage);
    glReadPixels(0, 0, (int)_size.width, (int)_size.height, GL_RGBA, GL_UNSIGNED_BYTE, rawImagePixels);
    dataProvider = CGDataProviderCreateWithData(NULL, rawImagePixels, totalBytesForImage,dataProviderReleaseCallback1);
    
    CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();
    
    cgImageFromBytes = CGImageCreate((int)_size.width, (int)_size.height, 8, 32, 4 * (int)_size.width, defaultRGBColorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaLast, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(defaultRGBColorSpace);
    
    return [UIImage imageWithCGImage:cgImageFromBytes];
}

- (CVOpenGLESTextureCacheRef)coreVideoTextureCache;
{
    if (_coreVideoTextureCache == NULL)
    {
#if defined(__IPHONE_6_0)
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.context, NULL, &_coreVideoTextureCache);
#else
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, (__bridge void *)self.content, NULL, &_coreVideoTextureCache);
#endif
        
        if (err)
        {
            NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreate %d", err);
        }

    }
    
    return _coreVideoTextureCache;
}

- (void)lockForReading{
    if ([VideoDirector supportsFastTextureUpload]) {
        if (readLockCount == 0) {
            CVPixelBufferLockBaseAddress(renderTarget, 0);
        }
        readLockCount ++;
    }
}

- (void)unlockAfterReading{
    if ([VideoDirector supportsFastTextureUpload]) {
        if (readLockCount == 0) {
            return;
        }
        readLockCount --;
        if (readLockCount == 0) {
            CVPixelBufferUnlockBaseAddress(renderTarget, 0);
        }
    }
}

+ (BOOL)supportsFastTextureUpload
{
    return (CVOpenGLESTextureCacheCreate != NULL);
    
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wtautological-pointer-compare"
    return (CVOpenGLESTextureCacheCreate != NULL);
#pragma clang diagnostic pop

#endif
}
void dataProviderReleaseCallback1 (void *info, const void *data, size_t size)
{
    free((void *)data);
}

void dataProviderUnlockCallback1 (void *info, const void *data, size_t size)
{
    
//    GPUImageFramebuffer *framebuffer = (__bridge_transfer GPUImageFramebuffer*)info;
//
//    [framebuffer restoreRenderTarget];
//    [framebuffer unlock];
//    [[GPUImageContext sharedFramebufferCache] removeFramebufferFromActiveImageCaptureList:framebuffer];
}

@end
