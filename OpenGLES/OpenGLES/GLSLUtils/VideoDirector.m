//
//  VideoDirector.m
//  OpenGLES
//
//  Created by wantexe on 2020/5/29.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import "VideoDirector.h"
#import <OpenGLES/ES2/gl.h>
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
        
        [self initRenderBuffer];
        
        [self initProgram];
        
    }
    return self;
}

- (void)initLayer{
    self.mfLayer = [CAEAGLLayer layer];
    
    self.mfLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:@false, kEAGLDrawablePropertyRetainedBacking, kEAGLDrawablePropertyColorFormat, kEAGLColorFormatRGBA8, nil];
}

- (void)initContext{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
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
    [view.layer addSublayer:self.mfLayer];
    
//    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.mfLayer];
//
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _frameBuffer);
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
    
    [self generateTexture];
    // 加载纹理
    [GLSLUtils readTextureForImage:image];
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture, 0);
    
    [self.mfProgram clearColorMap:"colorMap"];
    
    // 绘图
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    GLenum err = glCheckFramebufferStatus(GL_FRAMEBUFFER);
//    GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT
    NSLog(@"frame buffer status %u", err);
    if (err != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"frame buffer error");
    }
    
    if (self.mfLayer) {
//        [self.context presentRenderbuffer:GL_RENDERBUFFER];
    }
}

- (void)generateTexture{
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//    // This is necessary for non-power-of-two textures
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
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
    
    
//    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
//    glViewport(0, 0, (int)_size.width, (int)_size.height);
    
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
