//
//  FilterView.m
//  OpenGLES
//
//  Created by 李明锋 on 2020/5/10.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import "FilterView.h"
#import <OpenGLES/ES3/gl.h>
#import "GLSLUtils.h"

@interface FilterView (){
    float width;
    float height;
    float scale;
}
@property (nonatomic, strong) CAEAGLLayer *myLayer;
@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLuint renderBuffer;
@property (nonatomic, assign) GLuint frameBuffer;

@end

@implementation FilterView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _filterName = @"normal";
        width = self.frame.size.width;
        height = self.frame.size.height;
        scale = [UIScreen mainScreen].scale;
        [self setupLayer];
        [self setupBuffer];
        [self render];
    }
    return self;
}

- (void)setupLayer{
    self.myLayer = [CAEAGLLayer layer];
    self.myLayer.frame = self.bounds;
    [self.myLayer setContentsScale:scale];
    [self.layer addSublayer:self.myLayer];
    
    self.myLayer.drawableProperties = @{@false:kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8
    };
    
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (context==nil) {
        exit(1);
    }
    self.context = context;
    if (![EAGLContext setCurrentContext:context]) {
        exit(1);
    }
    
}

- (void)setupBuffer{
    // 清空
    glDeleteRenderbuffers(1, &_renderBuffer);
    _renderBuffer = 0;
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    
    // 开辟
    glGenRenderbuffers(1, &_renderBuffer);
    glGenFramebuffers(1, &_frameBuffer);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myLayer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
}

- (void)render{
    glViewport(0, 0, width*scale, height*scale);
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    if (self.filterName==nil) {
        return;
    }
    NSString *vFile = [[NSBundle mainBundle] pathForResource:self.filterName ofType:@"vsh"];
    NSString *fFile = [[NSBundle mainBundle] pathForResource:self.filterName ofType:@"fsh"];
    
    self.program = [GLSLUtils loadShaderProgramFrom:vFile fragFile:fFile];
    
    glLinkProgram(self.program);
    
    GLint linkStatus;
    glGetProgramiv(self.program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus==GL_FALSE) {
        GLchar msg[256];
        glGetProgramInfoLog(self.program, sizeof(msg), 0, &msg[0]);
        NSString *info = [NSString stringWithUTF8String:msg];
        NSLog(@"%@", info);
        return;
    }
    NSLog(@"link success!");
    glUseProgram(self.program);
    
    
    // 顶点
    float sub = 0.5;
    GLfloat points[] = {
        -sub,  sub, 0,    0, 1,
        -sub, -sub, 0,    0, 0,
         sub, -sub, 0,    1, 0,
         sub,  sub, 0,    1, 1
    };
    
    // 开辟顶点缓冲区
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    
    // copy and use
    // 将顶点数据copy到顶点缓冲区，并且设置其可用，一次性
    glBufferData(GL_ARRAY_BUFFER, sizeof(points), points, GL_STATIC_DRAW);
    
    GLint position = glGetAttribLocation(self.program, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);
    
    GLint textCoord = glGetAttribLocation(self.program, "vTextCoor");
    glEnableVertexAttribArray(textCoord);
    glVertexAttribPointer(textCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL+3);
    
    // 加载纹理
    [GLSLUtils readTexture:@"nature"];
    // 取色
    glUniform1i(glGetUniformLocation(self.program, "colorMap"), 0);
    
    // 绘制
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setFilterName:(NSString *)filterName{
    _filterName = filterName;
    [self render];
}

@end
