//
//  main.cpp
//  颜色混合
//
//  Created by wantexe on 2020/4/20.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#include <stdio.h>

#include "glew.h"
#include "GLTools.h"
#include "GLFrame.h"
#include <GLUT/GLUT.h>

GLBatch triangleBatch;
GLBatch leftTriangle;
GLBatch rightTriangle;

GLShaderManager shaderManager;

float gap = 1/3.0;

GLfloat movePoints[] = {
       0,  gap, 0,
    -gap, -gap, 0,
     gap, -gap, 0
};

void changeSize(int w, int h) {
    glViewport(0, 0, w, h);
}

void render() {
    glClear(GL_COLOR_BUFFER_BIT);
    
    GLfloat color1[] = {1.0, 0.0, 0.0, 0.2};
    GLfloat color2[] = {0.0, 1.0, 0.0, 0.2};
    GLfloat color3[] = {0.0, 0.0, 1.0, 0.8};
    
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, color1);
    leftTriangle.Draw();
    
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, color2);
    rightTriangle.Draw();
    
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, color3);
    triangleBatch.Draw();
    
    glutSwapBuffers();
    
}

void setup() {
    glClearColor(0, 0.5, 0.5, 1);
    
    // 开启混合
    glEnable(GL_BLEND);
    // 混合因子
    glBlendFunc(GL_DST_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    shaderManager.InitializeStockShaders();
    
    GLfloat points1[] = {
        -2*gap, -1*gap, 0,
        -1*gap, -1*gap, 0,
        -1*gap, -2*gap, 0
    };
    
    GLfloat points2[] = {
        2*gap, 1*gap, 0,
        1*gap, 1*gap, 0,
        1*gap, 2*gap, 0
    };
    
    
    leftTriangle.Begin(GL_TRIANGLES, 3);
    leftTriangle.CopyVertexData3f(points1);
    leftTriangle.End();
    
    rightTriangle.Begin(GL_TRIANGLES, 3);
    rightTriangle.CopyVertexData3f(points2);
    rightTriangle.End();
    
    triangleBatch.Begin(GL_TRIANGLES, 3);
    triangleBatch.CopyVertexData3f(movePoints);
    triangleBatch.End();
    
}

void move(int key, int x, int y) {
    float x1 = 0.0, y1 = 0.0;
    if (key == GLUT_KEY_UP) {
        y1 += 0.05;
    }
    if (key == GLUT_KEY_DOWN) {
        y1 -= 0.05;
    }
    if (key == GLUT_KEY_LEFT) {
        x1 -= 0.05;
    }
    if (key == GLUT_KEY_RIGHT) {
        x1 += 0.05;
    }
    movePoints[0] = movePoints[0]+x1;
    movePoints[1] = movePoints[1]+y1;
    
    movePoints[3] = movePoints[3]+x1;
    movePoints[4] = movePoints[4]+y1;
    
    movePoints[6] = movePoints[6]+x1;
    movePoints[7] = movePoints[7]+y1;
    
    triangleBatch.Begin(GL_TRIANGLES, 3);
    triangleBatch.CopyVertexData3f(movePoints);
    triangleBatch.End();
    
    glutPostRedisplay();
}

int main(int argc, char * argv[]) {
    
    gltSetWorkingDirectory(argv[0]);
    
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE|GLUT_RGBA);
    glutInitWindowSize(600, 400);
    glutCreateWindow("blend");
    
    GLenum err = glewInit();
    if (err != GLEW_OK) {
        printf("error \n");
        return 1;
    }
    
    glutDisplayFunc(render);
    glutReshapeFunc(changeSize);
    glutSpecialFunc(move);
    
    setup();
    
    glutMainLoop();
    
    return 0;
}
