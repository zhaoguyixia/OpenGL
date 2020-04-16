//
//  main.m
//  三角形
//
//  Created by wantexe on 2020/4/16.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#include <stdio.h>
#include "glew.h"

#include "GLTools.h"
#include "GLBatch.h"
#include <GLUT/GLUT.h>

GLBatch triangleBatch;
GLShaderManager shaderManager;

void changeSize(int w, int h){
    glViewport(0, 0, w, h);
}

void render(){
    glClear(GL_COLOR_BUFFER_BIT);
    
    GLfloat color[] = {0, 0, 0, 0};
    
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, color);
    triangleBatch.Draw();
    
    glutSwapBuffers();
}

void setup(){
    glClearColor(1, 1, 1, 0);
    
    shaderManager.InitializeStockShaders();
    
    GLfloat points[] = {
        -0.5, -0.5, 0,
         0.5, -0.5, 0,
         0.0,  0.5, 0
    };
    
    triangleBatch.Begin(GL_TRIANGLES, 3);
    triangleBatch.CopyVertexData3f(points);
    triangleBatch.End();
    
}

int main(int argc, char * argv[]) {
    
    gltSetWorkingDirectory(argv[0]);
    glutInit(&argc, argv);
    // 初始化展示模式,默认是GLUT_RGBA
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_STENCIL);
    glutInitWindowSize(600, 400);
    glutCreateWindow("三角形");
    
    glutReshapeFunc(changeSize);
    glutDisplayFunc(render);
    
    GLenum err = glewInit();
    if (err != GLEW_OK) {
        printf("error");
        return 1;
    }
    
    setup();
    glutMainLoop();
    
    return 0;
}
