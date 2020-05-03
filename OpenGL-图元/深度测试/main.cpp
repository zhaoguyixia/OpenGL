//
//  main.m
//  深度测试
//
//  Created by 李明锋 on 2020/4/25.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#import "stdio.h"

#include "glew.h"
#include <GLUT/GLUT.h>
#include "GLTools.h"
#include "GLFrame.h"

GLBatch triangleBatch1;

GLBatch triangleBatch2;

GLBatch triangleBatch3;

GLShaderManager shaderManager;

void changeSize(int w, int h) {
    glViewport(0, 0, w, h);
}

void render() {
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_DEPTH_TEST);
    
    GLfloat color1[] = {1,0,0,0};
    GLfloat color2[] = {0,1,0,0};
    GLfloat color3[] = {0,0,1,0};
    
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, color1);
    triangleBatch1.Draw();
    
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, color3);
    triangleBatch3.Draw();
    
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, color2);
    triangleBatch2.Draw();
    
    
    
    glutSwapBuffers();
}

void setup() {
    
    glClearColor(0, 0, 0, 1.0);
    
    shaderManager.InitializeStockShaders();
    
    GLfloat points1[] = {
        0.2,  0.5, 0,
        0.3,  0.5, 0,
       -0.4, -0.5, 0,
       -0.5, -0.5, 0,
    };
    
    GLfloat points2[] = {
        -0.2,  0.5, -1,
        -0.3,  0.5, -1,
         0.4, -0.5, -1,
         0.5, -0.5, -1,
    };
    
    GLfloat points3[] = {
        -0.5,  0.0, 0,
        -0.5, -0.1, 0,
         0.5, -0.1, 0,
         0.5,  0.0, 0,
    };
    
    triangleBatch1.Begin(GL_TRIANGLE_FAN, 4);
    triangleBatch1.CopyVertexData3f(points1);
    triangleBatch1.End();
    
    triangleBatch2.Begin(GL_TRIANGLE_FAN, 4);
    triangleBatch2.CopyVertexData3f(points2);
    triangleBatch2.End();
    
    triangleBatch3.Begin(GL_TRIANGLE_FAN, 4);
    triangleBatch3.CopyVertexData3f(points3);
    triangleBatch3.End();
    
}

int main(int argc, char * argv[]) {
    
    gltSetWorkingDirectory(argv[0]);
    
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_RGBA);
    glutInitWindowSize(600, 400);
    glutCreateWindow("深度测试");
    
    GLenum err = glewInit();
    if (err != GLEW_OK) {
        printf("error \n");
        return 1;
    }
    
    glutReshapeFunc(changeSize);
    glutDisplayFunc(render);
    
    setup();
    
    glutMainLoop();
    
    return 0;
}
