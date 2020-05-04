//
//  main.cpp
//  纹理-基础
//
//  Created by wantexe on 2020/5/4.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#include <stdio.h>
#include "glew.h"
#include "GLTools.h"
#include <GLUT/GLUT.h>
#include "GLBatch.h"
#include "GLMatrixStack.h"
#include "GLGeometryTransform.h"
#include "GLFrustum.h"

const char *file = "/Users/wantexe/Desktop/OpenGL-系列/OpenGL-图元/stone.tga";

GLfloat points[] = {
    -0.5,  0.5, 0,
    -0.5, -0.5, 0,
     0.5, -0.5, 0,
     0.5,  0.5, 0,
};

GLfloat point00[] = {-0.5, -0.5, 0};
GLfloat point10[] = { 0.5, -0.5, 0};
GLfloat point01[] = {-0.5,  0.5, 0};
GLfloat point11[] = { 0.5,  0.5, 0};

GLBatch squareBatch;
/// 纹理ID
GLuint textureID;

GLShaderManager shaderManager;

GLFrustum viewFrustum;

GLFrame cameraFrame;

GLMatrixStack modelViewMatrix;
GLMatrixStack projectionMatrix;

GLGeometryTransform transformLine;

void changeSize(int w, int h) {
    glViewport(0, 0, w, h);
    if (h == 0) {
        h = 1;
    }
    viewFrustum.SetPerspective(20, float(w)/float(h), 1, 100);
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    modelViewMatrix.LoadIdentity();
    transformLine.SetMatrixStacks(modelViewMatrix, projectionMatrix);
}

void render() {
    glClear(GL_COLOR_BUFFER_BIT);
    
    M3DMatrix44f mCamera;
    cameraFrame.GetCameraMatrix(mCamera);
    modelViewMatrix.MultMatrix(mCamera);
    
    // 使用纹理替换矩阵
    shaderManager.UseStockShader(GLT_SHADER_TEXTURE_REPLACE, transformLine.GetModelViewProjectionMatrix(), 0);
    
    squareBatch.Draw();
    
    glutSwapBuffers();
}


bool loadTGATexture(const char *fileName) {
    
    GLbyte *pBits;
    
    int nWidth, nHeight, nComponents;
    GLenum eFormat;
    //1、读纹理位，读取像素
    //参数1：纹理文件名称
    //参数2：文件宽度地址
    //参数3：文件高度地址
    //参数4：文件组件地址
    //参数5：文件格式地址
    //返回值：pBits,指向图像数据的指针
    pBits = gltReadTGABits(fileName, &nWidth, &nHeight, &nComponents, &eFormat);
    if (pBits == NULL) {
        return false;
    }
    
    // 设置纹理参数
    
    // 环绕模式，可以试试不设置的效果
    // params1:纹理纬度
    // params2:OpenGL里面的横纵用s/t表示
    // params3:环绕模式，有多种，自行百度，例如：GL_REPEAT
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // 过滤方式
    // 纹理缩小时，用临近过滤
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    // 纹理放大时，用线性过滤
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // 载入纹理
    glTexImage2D(GL_TEXTURE_2D, 0, nComponents, nWidth, nHeight, 0, eFormat, GL_UNSIGNED_BYTE, pBits);
    // c,释放
    free(pBits);

    // 加载mip
    glGenerateMipmap(GL_TEXTURE_2D);
    
    return true;
}


void setup() {
    glClearColor(0.5, 0.5, 0.5, 0);
    
    shaderManager.InitializeStockShaders();
    
    // 绑定纹理
    
    // params1:纹理对象个数
    // params2:纹理对象指针
//    glGenTextures(1, &textureID);
    
    // 绑定纹理
    // 将GL_TEXTURE_2D与textureID关联，后续需要用到textureID
//    glBindTexture(GL_TEXTURE_2D, textureID);
    
    
    // 加载图片
    loadTGATexture(file);
    
    // 与之前画图元不一样
    /*
     参数1：类型
     参数2：顶点数
     参数3：这个批次中将会应用1个纹理
     */
    squareBatch.Begin(GL_TRIANGLE_FAN, 4, 1);
    
    // 设置顶点对应的纹理坐标
    // params1：texture，纹理层次，对于使用存储着色器来进行渲染，设置为0
    // params2：s: 对应顶点坐标中的x坐标
    // params3：t: 对应顶点坐标中的y
    squareBatch.MultiTexCoord2f(0, 0, 0);
    squareBatch.Vertex3fv(point00);
    
    squareBatch.MultiTexCoord2f(0, 1, 0);
    squareBatch.Vertex3fv(point10);
    
    squareBatch.MultiTexCoord2f(0, 1, 1);
    squareBatch.Vertex3fv(point11);
    
    squareBatch.MultiTexCoord2f(0, 0, 1);
    squareBatch.Vertex3fv(point01);
    
    squareBatch.End();
    
    cameraFrame.MoveForward(-5);
}

int main(int argc, char * argv[]) {
    
    gltSetWorkingDirectory(argv[0]);
    glutInit(&argc, argv);
    glutInitWindowSize(600, 600);
    glutCreateWindow("纹理-基础");
    
    glutReshapeFunc(changeSize);
    glutDisplayFunc(render);
    
    GLenum err = glewInit();
    if (err != GLEW_OK) {
        printf("error \n");
        return 1;
    }
    
    setup();
    
    glutMainLoop();
    
    return 0;
}
