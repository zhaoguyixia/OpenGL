//
//  TextureView.m
//  OpenGLES
//
//  Created by 李明锋 on 2020/5/6.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import "TextureView.h"
#import <OpenGLES/ES3/gl.h>

@interface TextureView ()
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint program;
@property (nonatomic, strong) CAEAGLLayer *myLayer;

@property (nonatomic, assign) GLuint renderBuffer;
@property (nonatomic, assign) GLuint frameBuffer;

@end

@implementation TextureView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.width = frame.size.width;
        self.height = frame.size.height;
        
        [self setupLayer];
        
        [self setupContent];
        
        [self clearBuffer];
        
        [self setupBuffer];
        
        [self render];
        
    }
    return self;
}

- (void)setupLayer{
    self.myLayer = [CAEAGLLayer layer];
    self.myLayer.frame = self.bounds;
    [self.myLayer setContentsScale:[UIScreen mainScreen].scale];
    [self.layer addSublayer:self.myLayer];
    
    self.myLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:@false, kEAGLDrawablePropertyRetainedBacking, kEAGLDrawablePropertyColorFormat, kEAGLColorFormatRGBA8, nil];
    
    glViewport(0, 0, self.width, self.height);
}

- (void)setupContent{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context) {
        exit(1);
    }
    self.context = context;
    BOOL result = [EAGLContext setCurrentContext:self.context];
    if (!result) {
        exit(1);
    }
}
/// 清空渲染缓冲区和帧缓冲区
- (void)clearBuffer{
    glDeleteRenderbuffers(1, &_renderBuffer);
    _renderBuffer = 0;
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
}
/// 开辟缓冲区
- (void)setupBuffer{
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myLayer];
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _frameBuffer);
}

- (void)render{
    
    glClearColor(0.5, 0.5, 0.5, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
