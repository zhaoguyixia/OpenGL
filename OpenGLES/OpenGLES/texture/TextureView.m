//
//  TextureView.m
//  OpenGLES
//
//  Created by 李明锋 on 2020/5/6.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import "TextureView.h"
#import <OpenGLES/ES3/gl.h>
#import "GLSLUtils.h"

@interface TextureView ()
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) GLuint program;

@property (nonatomic, strong) EAGLContext *context;
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
    
    self.myLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @false, kEAGLDrawablePropertyRetainedBacking,
                                       kEAGLDrawablePropertyColorFormat, kEAGLColorFormatRGBA8, nil];
    
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
    float scale = [UIScreen mainScreen].scale;
    glViewport(0, 0, self.width*scale, self.height*scale);
    
    glClearColor(0.5, 0.5, 0.5, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    NSString *vFile = [[NSBundle mainBundle] pathForResource:@"normal" ofType:@"vsh"];
    NSString *fFile = [[NSBundle mainBundle] pathForResource:@"normal" ofType:@"fsh"];
    
    self.program = [GLSLUtils loadShaderProgramFrom:vFile fragFile:fFile];
    
    // 链接
    glLinkProgram(self.program);
    
    GLint linkStatus;
    glGetProgramiv(self.program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar msg[512];
        glGetProgramInfoLog(self.program, sizeof(msg), 0, &msg[0]);
        NSString *info = [NSString stringWithUTF8String:msg];
        NSLog(@"%@", info);
        return;
    }
    NSLog(@"link success!");
    
    glUseProgram(self.program);
    
    float sub = 1.0;
    
    // 设置顶点、纹理坐标
    GLfloat points[] = {
        -sub, -sub, 0,    0, 0,
         sub, -sub, 0,    1, 0,
         sub,  sub, 0,    1, 1,
        -sub,  sub, 0,    0, 1,
    };
    
    // 开辟顶点缓冲区
    GLuint vexBuffer;
    glGenBuffers(1, &vexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vexBuffer);
    // 第一个参数target可以为GL_ARRAY_BUFFER或GL_ELEMENT_ARRAY。
    // 第二个参数size为待传递数据字节数量
    // 第三个参数为源数据数组指针，如data为NULL，则VBO仅仅预留给定数据大小的内存空间。
    // 最后一个参数usage标志位VBO的另一个性能提示，它提供缓存对象将如何使用：static、dynamic或stream、与read、copy或draw。
    glBufferData(GL_ARRAY_BUFFER, sizeof(points), points, GL_STATIC_DRAW);
    
    
    // 使用自定义着色器程序
    GLuint position = glGetAttribLocation(self.program, "position");
    // 允许顶点着色器读取GPU（服务器端）数据
    glEnableVertexAttribArray(position);
    // 读取方式
    /*
     参数1:用什么着色器，这里是顶点着色器 position 顶点数据ID
     参数2:每次读取字节数 数量
     参数3:数据类型
     参数4:是否希望数据被标准化（归一化），只表示方向不表示大小
     参数5:步长（Stride），指定在连续的顶点属性之间的间隔
     参数6:位置数据在缓冲区起始位置的偏移量
     */
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);
    
    // 片源着色器
    GLuint vTextCoor = glGetAttribLocation(self.program, "vTextCoor");
    glEnableVertexAttribArray(vTextCoor);
    glVertexAttribPointer(vTextCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat *)NULL+3);
    
    // 加载纹理
    [GLSLUtils readTexture:@"girl"];
    // 设置纹理采样器
    glUniform1i(glGetUniformLocation(self.program, "colorMap"), 0);
    // 绘图
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
