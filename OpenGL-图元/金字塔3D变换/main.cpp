//
//  main.cpp
//  金字塔3D变换
//
//  Created by wantexe on 2020/4/16.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#include <stdio.h>

#include "glew.h"
#include "GLTools.h"
#include <GLUT/GLUT.h>
#include "GLBatch.h"
#include "GLFrame.h"
#include "GLFrustum.h"
#include "GLMatrixStack.h"
#include "GLGeometryTransform.h"
#include "math3d.h"

// 用来画金字塔
GLBatch triangleBatch;
GLShaderManager shaderManager;
//GLGeometryTransform transformPipeLine;
/*
 void glPerspective(GLdouble fov, GLdouble aspect, GLdouble near, GLdouble far)
 fov是依据y方向的视角，aspect是近裁剪面的纵横比，当然远裁剪面也取这个值，near和far的意义和上面的一样。
 透视投影的一个问题就是深度精度的损失，在显示设备中该问题很明显。问题出在深度缓存中深度的限制以及由透视投影引起的非线性比例变换。
 当近裁剪面非常靠近投影中心的时候，误差就非常大。
*/
// 透视投影
GLFrustum viewFrustum;
// 视图矩阵堆栈
GLMatrixStack modelViewMatrix;
// 模型矩阵堆栈
GLMatrixStack projectionMatrix;

// 观察者
GLFrame objectFrame;

void changeSize(int w, int h) {
    glViewport(0, 0, w, h);
    if (h==0) {
        h = 1;
    }
    viewFrustum.SetPerspective(20, float(w)/float(h), 1, 100);
    
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    
//    transformPipeLine.SetMatrixStacks(modelViewMatrix, projectionMatrix);
    
}

void render() {
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_DEPTH_TEST) ;
    
    GLfloat color[] = {1.0, 0, 0, 0};
    
//    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, color);
//    modelViewMatrix.MultMatrix(objectFrame);
    
    modelViewMatrix.PushMatrix(projectionMatrix.GetMatrix());
    
    modelViewMatrix.MultMatrix(objectFrame);
    
//    modelViewMatrix.PushMatrix(objectFrame);
//
//
//    M3DMatrix44f projectMatrix;
//    projectionMatrix.GetMatrix(projectMatrix);
//
//    modelViewMatrix.MultMatrix(projectMatrix);
    
    M3DMatrix44f mCamera;
    objectFrame.GetMatrix(mCamera);

    M3DMatrix44f modelViewProjection;
    m3dMatrixMultiply44(modelViewProjection, viewFrustum.GetProjectionMatrix(), mCamera);
    
    shaderManager.UseStockShader(GLT_SHADER_FLAT, modelViewProjection, color);
    
    glLineWidth(2);
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    
    triangleBatch.Draw();
    
    modelViewMatrix.PopMatrix();
    
    glutSwapBuffers();
}

void setup() {
    glClearColor(1, 1, 1, 1.0);
    
    objectFrame.MoveForward(7);
//
//    objectFrame.RotateWorld(m3dDegToRad(45), 1, 0, 0);
    
    shaderManager.InitializeStockShaders();
    
    float top = 0.5;
    float bottom = - 0.5;
    float y = 0.5;
    float x = 0.5;
    
    GLfloat points[] = {
        // 底部
        -x, -y, bottom,
         x, -y, bottom,
         0,  y, bottom,
        
        // 侧面1
        -x, -y, bottom,
         x, -y, bottom,
         0,  0, top,
        
        // 侧面2
         x, -y, bottom,
         0,  y, bottom,
         0,  0, top,
        // 侧面3
         0,  y, bottom,
        -x, -y, bottom,
         0,  0, top,
    };
    
    triangleBatch.Begin(GL_TRIANGLES, 12);
    triangleBatch.CopyVertexData3f(points);
    triangleBatch.End();
    
}

void specialKey(int key, int x, int y) {
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
    glutInitDisplayMode(GLUT_DOUBLE|GLUT_RGBA|GLUT_DEPTH|GLUT_STENCIL);
    glutInitWindowSize(600, 400);
    glutCreateWindow("金字塔3D变换");
    
    glutDisplayFunc(render);
    glutReshapeFunc(changeSize);
    glutSpecialFunc(specialKey);
    
    GLenum err = glewInit();
    if (err != GLEW_OK) {
        printf("error ! \n");
        return 1;
    }
    
    setup();
    
    glutMainLoop();
    
    return 0;
}
