//
//  TextureView.m
//  OpenGLES
//
//  Created by 李明锋 on 2020/5/6.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import "TextureView.h"
#import "MFGLProgram.h"

@interface TextureView ()
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;

@property (nonatomic, assign) GLuint program;

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) MFGLProgram *mfProgram;
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
        
        [self initProgram];
        
        [self render];
        
    }
    return self;
}

- (void)setupLayer{
    self.myLayer = [CAEAGLLayer layer];
    self.myLayer.frame = self.bounds;
//    [self.myLayer setContentsScale:[UIScreen mainScreen].scale];
    [self.layer addSublayer:self.myLayer];
    
    self.myLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @false, kEAGLDrawablePropertyRetainedBacking,
                                       kEAGLDrawablePropertyColorFormat, kEAGLColorFormatRGBA8, nil];
    
}


- (void)setupContent{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
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

- (void)initProgram{
    NSString *vFile = [[NSBundle mainBundle] pathForResource:@"split" ofType:@"vsh"];
    NSString *fFile = [[NSBundle mainBundle] pathForResource:@"split" ofType:@"fsh"];
    self.mfProgram = [[MFGLProgram alloc] initWithVerFile:vFile fragFile:fFile];
    [self.mfProgram linkUseProgram];
}

- (void)render{
//    float scale = [UIScreen mainScreen].scale;
//    glViewport(0, 0, self.width*scale, self.height*scale);
    
    glViewport(0, 0, self.width, self.height);
    
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
    
    // 开辟顶点缓冲区
//    GLuint vexBuffer;
//    glGenBuffers(1, &vexBuffer);
//    glBindBuffer(GL_ARRAY_BUFFER, vexBuffer);
    // 第一个参数target可以为GL_ARRAY_BUFFER或GL_ELEMENT_ARRAY。
    // 第二个参数size为待传递数据字节数量
    // 第三个参数为源数据数组指针，如data为NULL，则VBO仅仅预留给定数据大小的内存空间。
    // 最后一个参数usage标志位VBO的另一个性能提示，它提供缓存对象将如何使用：static、dynamic或stream、与read、copy或draw。
//    glBufferData(GL_ARRAY_BUFFER, sizeof(points), points, GL_STATIC_DRAW);
    
    
    // 加载纹理
    [GLSLUtils readTexture:@"girl"];
    
    [self.mfProgram clearColorMap:"colorMap"];
    
    // 绘图
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
