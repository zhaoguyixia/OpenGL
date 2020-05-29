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
@property (nonatomic, strong) EAGLContext *content;
@property (nonatomic, assign) GLuint frameBuffer;
@property (nonatomic, strong) MFGLProgram *mfProgram;
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
        
        self.content = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        if (self.content) {
            [EAGLContext setCurrentContext:self.content];
        }
        
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
        glGenFramebuffers(1, &_frameBuffer);
        glBindBuffer(GL_FRAMEBUFFER, _frameBuffer);
        
        NSString *vFile = [[NSBundle mainBundle] pathForResource:@"split" ofType:@"vsh"];
        NSString *fFile = [[NSBundle mainBundle] pathForResource:@"split" ofType:@"fsh"];
        self.mfProgram = [[MFGLProgram alloc] initWithVerFile:vFile fragFile:fFile];
        [self.mfProgram linkUseProgram];
        
    }
    return self;
}


- (void)setImage:(UIImage *)image{
    _size = image.size;
    float scale = [UIScreen mainScreen].scale;
    float width = image.size.width;
    float height = image.size.height;
    glViewport(0, 0, width*scale, height*scale);
    
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
    [GLSLUtils readTextureForImage:image];
    
    
    [self.mfProgram clearColorMap:"colorMap"];
    
    // 绘图
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    [self.content presentRenderbuffer:GL_RENDERBUFFER];
    
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
    if ([VideoDirector supportsFastTextureUpload]) {
        NSUInteger paddedWidth = CVPixelBufferGetBytesPerRow(renderTarget);
        
        NSUInteger paddedBytesForImage = paddedWidth * (int)_size.height * 4;

        // ??
        glFinish();

        CFRetain(renderTarget);

        //
        [self lockForReading];

        rawImagePixels = (GLubyte *)CVPixelBufferGetBaseAddress(renderTarget);
        
        dataProvider = CGDataProviderCreateWithData((__bridge_retained void*)self, rawImagePixels, paddedBytesForImage, dataProviderUnlockCallback);
        
//        [self unlockAfterReading];
        
    }else{
        [self unlockAfterReading];
    }
    
    CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();
    
    if ([VideoDirector supportsFastTextureUpload]) {
        
        cgImageFromBytes = CGImageCreate((int)_size.width, (int)_size.height, 8, 32, CVPixelBufferGetBytesPerRow(renderTarget), defaultRGBColorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst, dataProvider, NULL, NO, kCGRenderingIntentDefault);
        
    }else{
        cgImageFromBytes = CGImageCreate((int)_size.width, (int)_size.height, 8, 32, 4 * (int)_size.width, defaultRGBColorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaLast, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    }
    
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(defaultRGBColorSpace);
    
    return [UIImage imageWithCGImage:cgImageFromBytes];
}

- (CVOpenGLESTextureCacheRef)coreVideoTextureCache;
{
    if (_coreVideoTextureCache == NULL)
    {
#if defined(__IPHONE_6_0)
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.content, NULL, &_coreVideoTextureCache);
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

void dataProviderUnlockCallback (void *info, const void *data, size_t size)
{
    
//    GPUImageFramebuffer *framebuffer = (__bridge_transfer GPUImageFramebuffer*)info;
//
//    [framebuffer restoreRenderTarget];
//    [framebuffer unlock];
//    [[GPUImageContext sharedFramebufferCache] removeFramebufferFromActiveImageCaptureList:framebuffer];
}

@end
