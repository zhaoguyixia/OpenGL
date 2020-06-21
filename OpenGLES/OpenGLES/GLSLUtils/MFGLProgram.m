//
//  MFGLProgram.m
//  OpenGLES
//
//  Created by zhaoguyixia on 2020/5/29.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import "MFGLProgram.h"


@interface MFGLProgram ()
@property (nonatomic, assign) GLuint program;
@end

@implementation MFGLProgram

- (instancetype)initWithVerFile:(NSString *)verFile fragFile:(NSString *)fragFile{
    if (self = [super init]) {
        self.program = [GLSLUtils loadShaderProgramFrom:verFile fragFile:fragFile];
    }
    return self;
    
}

- (void)linkUseProgram{
    // 链接
    glLinkProgram(self.program);
    
    GLint linkStatus;
    glGetProgramiv(self.program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar msg[512];
        glGetProgramInfoLog(self.program, sizeof(msg), 0, &msg[0]);
        NSString *info = [NSString stringWithUTF8String:msg];
        NSLog(@"link fail  %@", info);
        return;
    }
    NSLog(@"link success!");
    
    glUseProgram(self.program);
}

- (void)useDefaultSample:(GLchar *)colorMapKey{
    glUniform1i(glGetUniformLocation(self.program, colorMapKey), 0);
}

- (void)letSample:(GLchar *)colorMapKey useTexture:(GLint)textureId{
    glUniform1i(glGetUniformLocation(self.program, colorMapKey), textureId);
}

- (void)useLocationAttribute:(GLchar *)attributeKey
                perReadCount:(GLint)perCount
                      points:(GLfloat *)points{
 
    GLuint targetArribute = glGetAttribLocation(self.program, attributeKey);
    glEnableVertexAttribArray(targetArribute);
    glVertexAttribPointer(targetArribute, perCount, GL_FLOAT, 0, 0, points);
    
}

@end

