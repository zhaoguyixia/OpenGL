//
//  FilterView.m
//  OpenGLES
//
//  Created by 李明锋 on 2020/5/10.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import "FilterView.h"
#import <OpenGLES/ES2/gl.h>
#import "GLSLUtils.h"

@interface FilterView (){
    float width;
    float height;
//    float scale;
    NSTimer *timer;
    float filterScale;
    int direction;
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
        _vortexSub = 0.0;
        direction = 1;
        _imageName = @"girl2";
        filterScale = 0;
        width = self.frame.size.width;
        height = self.frame.size.height;
//        scale = [UIScreen mainScreen].scale;
        [self setupLayer];
        [self setupBuffer];
        [self render];
    }
    return self;
}

- (void)setupLayer{
    self.myLayer = [CAEAGLLayer layer];
    self.myLayer.frame = self.bounds;
//    [self.myLayer setContentsScale:scale];
    [self.layer addSublayer:self.myLayer];
    
    self.myLayer.drawableProperties = @{@false:kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8
    };
    
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
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
    glViewport(0, 0, width, height);
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
    [GLSLUtils readTexture:_imageName];
    
//    static float vor = 0.1;
    
    if ([self.filterName isEqualToString:@"vortex"]) {
        GLint vortex = glGetUniformLocation(self.program, "yinzi");
        glUniform1f(vortex, self.vortexSub);
    } else if ([self.filterName isEqualToString:@"mosaic"]) {
        GLint rowCount = glGetUniformLocation(self.program, "rowCount");
        if (self.vortexSub < 0.1) {
            _vortexSub = 0.1;
        }
        _vortexSub *= 10;
        glUniform1i(rowCount, (int)self.vortexSub);
    } else if ([self.filterName isEqualToString:@"soul"]) {
        GLint sourScale = glGetUniformLocation(self.program, "scale");
        glUniform1f(sourScale, filterScale);
    }
    
    // 取色
    glUniform1i(glGetUniformLocation(self.program, "colorMap"), 0);
    
    // 绘制
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setFilterName:(NSString *)filterName{
    _filterName = filterName;
    if ([self.filterName isEqualToString:@"soul"]) {
        [self startTimer];
    }else{
        [self render];
        [self stop];
    }
    
}

- (void)setVortexSub:(float)vortexSub{
    _vortexSub = vortexSub;
    if ([self.filterName isEqualToString:@"vortex"] || [self.filterName isEqualToString:@"mosaic"]) {
        [self render];
    }
}

- (void)setImageName:(NSString *)imageName{
    _imageName = imageName;
    if ([imageName length]) {
        [self render];
    }
}

- (void)stop{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)startTimer{
    if (timer == nil) {
        __weak typeof(self) weakSelf = self;
        if (@available(iOS 10.0, *)) {
            timer = [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
                [weakSelf soulMove];
            }];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        } else {
            // Fallback on earlier versions
        }
    }
}

- (void)soulMove{
    if (filterScale >= 0.3) {
        filterScale = 0;
    }
//    else if (filterScale<=0) {
//        direction = 1;
//    }
    filterScale += (0.03 * direction);
    [self render];
}

@end
