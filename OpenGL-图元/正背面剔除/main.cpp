//
//  main.cpp
//  正背面剔除
//
//  Created by wantexe on 2020/4/21.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#include <stdio.h>

#include "point.h"
#include "GLTools.h"
#include "GLFrustum.h"
#include "GLFrame.h"
#include <GLUT/GLUT.h>

GLShaderManager shaderManager;

/// 投影
GLFrustum viewFrustum;

GLFrame objectFrame;

GLBatch batch1, batch2, batch3, batch4, batch5, batch6;

GLBatch lineBatch1, lineBatch2, lineBatch3, lineBatch4, lineBatch5, lineBatch6;

GLBatch batchs[6] = {batch1, batch2, batch3, batch4, batch5, batch6};

GLBatch lineBatchs[6] = {lineBatch1, lineBatch2, lineBatch3, lineBatch4, lineBatch5, lineBatch6};

GLfloat *points[6] = {cubeFront, cubeBack, cubeLeft, cubeRight, cubeTop, cubeBottom};

GLfloat *colors[6] = {color1, color2, color3, color4, color5, color6};

int FLAT_COUNT = 6;

bool isCull = false;

void changeSize(int w, int h) {
    glViewport(0, 0, w, h);
    if (h == 0 ) {
        h = 1;
    }
    viewFrustum.SetPerspective(35, float(w)/float(h), 1, 100);
}

void render() {
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
    
    GLfloat lineColor[] = {0, 0, 0, 1};
    
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
//    glEnable(GL_DEPTH_TEST);
    
    
    M3DMatrix44f object;
    objectFrame.GetMatrix(object);
    
    M3DMatrix44f matrix;
    m3dMatrixMultiply44(matrix, viewFrustum.GetProjectionMatrix(), object);
    
    for (int i=0; i<FLAT_COUNT; i++) {
            
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        glLineWidth(2);
        glPolygonOffset(-1, -1);
        glEnable(GL_LINE_SMOOTH);
        
        shaderManager.UseStockShader(GLT_SHADER_FLAT, matrix, lineColor);
        batchs[i].Draw();
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        
        shaderManager.UseStockShader(GLT_SHADER_FLAT, matrix, colors[i]);
        batchs[i].Draw();
    }
    
    glutSwapBuffers();
}

void setup() {
    glClearColor(0.5, 0.5, 0.5, 1);
    
    objectFrame.MoveForward(7);
    
    shaderManager.InitializeStockShaders();
    
    
    for (int i=0; i<FLAT_COUNT; i++) {
        batchs[i].Begin(GL_TRIANGLE_FAN, 4);
        batchs[i].CopyVertexData3f(points[i]);
        batchs[i].End();
        
    }
    
}

void move(int key, int x, int y) {
    
    if (key == GLUT_KEY_UP) {
        objectFrame.RotateWorld(m3dDegToRad(5), 1, 0, 0);
    }
    
    if (key == GLUT_KEY_DOWN) {
        objectFrame.RotateWorld(m3dDegToRad(-5), 1, 0, 0);
    }
    
    if (key == GLUT_KEY_LEFT) {
        objectFrame.RotateWorld(m3dDegToRad(5), 0, 1, 0);
    }
    
    if (key == GLUT_KEY_RIGHT) {
        objectFrame.RotateWorld(m3dDegToRad(-5), 0, 1, 0);
    }
    
    glutPostRedisplay();
}

int main(int argc, char * argv[]) {
    
    gltSetWorkingDirectory(argv[0]);
    
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE|GLUT_RGBA);
    glutInitWindowSize(600, 400);
    glutCreateWindow("front back cull");
    
    GLenum err = glewInit();
    if (err != GLEW_OK) {
        printf("hello error \n");
        return 1;
    }
    
    glutReshapeFunc(changeSize);
    glutDisplayFunc(render);
    glutSpecialFunc(move);
    
    setup();
    glutMainLoop();
    
    return 0;
}
