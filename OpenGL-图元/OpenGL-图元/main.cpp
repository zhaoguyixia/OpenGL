//
//  main.c
//  OpenGL-图元
//
//  Created by wantexe on 2020/4/13.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#include <stdio.h>

#include "glew.h"
#include "GLTools.h"
#include "GLTriangleBatch.h"
#include "GLFrame.h"
#include <GLUT/GLUT.h>

// 定义一个着色器程序，因为绘制需要着色器
GLShaderManager shaderManager;



GLBatch pointBatch;

GLBatch lineBatch;

GLBatch lineStripBatch;

GLBatch lineLoopBatch;

GLBatch triangleBatch;

GLBatch triangleStripBatch;

GLBatch triangleFanBatch;

void changeSize(int w, int h){
    glViewport(0, 0, w, h);
}

void render(){
    // 没有开颜色混合前，alpha值是不会影响颜色的
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLfloat color[] = {0.5, 0.5, 0.5, 0.0};
    
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, color);
    
    triangleBatch.Draw();
    
    // 线段，利用OpenGL的状态机特性(不设置会一直保留当前状态)，复用 shaderManager.UseStockShader(GLT_SHADER_IDENTITY, color);
    // 或者换一种颜色
    GLfloat lineColor[] = {0.0, 0.0, 0.0, 0.0};
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, lineColor);
    glLineWidth(1.0);
    lineBatch.Draw();
    
    // 点，直接复用上述line的黑色
    glPointSize(20);
    pointBatch.Draw();
    
    // 线带
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, color);
    lineStripBatch.Draw();
    
    // 线环
    GLfloat loopColor[] = {1.0, 0.0, 0.0, 0.0};
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, loopColor);
    lineLoopBatch.Draw();
    
    // 三角带，为了能观察三角形的位置，这里用线段模式
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    
    triangleStripBatch.Draw();
    
    triangleFanBatch.Draw();
    
    // 交换缓冲区，把当前的缓冲区提交，显示在屏幕上，
    // OpenGL是状态机，绘制一个缓冲区之后，需要显示它时就要交换缓冲区，否则还是显示上一个缓冲区里面的内容。
    glutSwapBuffers();
    
}

void setup(){
    // 设置清空屏幕的颜色
    glClearColor(0.0, 1.0, 1.0, 0);
    // 用上面的颜色清空 颜色缓冲区GL_COLOR_BUFFER_BIT，如果需要用到深度测试，则还需要清空深度缓冲区GL_DEPTH_BUFFER_BIT
    // 执行顺序不能打乱，可以试下颠倒顺序后的效果
    // 放在render里面和这里都可以，render里面可能会清空多次
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // render这个方法会重复使用，但是着色器程序只需要初始化一次，所以着色器的初始化放在配置方法里面，执行一次即可
    shaderManager.InitializeStockShaders();
    
    GLfloat triangles[] = {
        -0.75, -0.75, 0,
        -0.25, -0.75, 0,
        -0.50, -0.25, 0
    };
    // 开始绘制
    // param1: 绘制的图形，这里绘制一个三角形GL_TRIANGLES
    // param2: 顶点数量，一个三角形3个顶点，一个正方形由两个三角形组成6个顶点
    triangleBatch.Begin(GL_TRIANGLES, 3);
    // 将顶点数据写入triangleBatch
    triangleBatch.CopyVertexData3f(triangles);
    // OK，绘制在render里面，所以draw方法在render里面
    triangleBatch.End();
    
    // 线，与上诉步骤一样
    GLfloat lines[] = {
        -1.0, 0.0, 0.0,
         1.0, 0.0, 0.0,
         0.0, 1.0, 0.0,
         0.0,-1.0, 0.0
    };
    lineBatch.Begin(GL_LINES, 4);
    lineBatch.CopyVertexData3f(lines);
    lineBatch.End();
    
    // 点
    GLfloat points[] = {
        -0.75, 0.75, 0.0,
        -0.75, 0.25, 0.0,
        -0.25, 0.75, 0.0,
        -0.25, 0.25, 0.0
    };
    
    pointBatch.Begin(GL_POINTS, 4);
    pointBatch.CopyVertexData3f(points);
    pointBatch.End();
    
    float hSub = 1.0/5.0;
    float vSub = 1.0/3.0;
    // 线带
    GLfloat lineStrip[] = {
        1*hSub, 1*vSub, 0.0,
        1*hSub, 2*vSub, 0.0,
        2*hSub, 2*vSub, 0.0,
        2*hSub, 1*vSub, 0.0,
    };
    
    lineStripBatch.Begin(GL_LINE_STRIP, 4);
    lineStripBatch.CopyVertexData3f(lineStrip);
    lineStripBatch.End();
    
    // 线环，在线带的基础上闭环，也就是首尾相连
    GLfloat lineLoop[] = {
        3*hSub, 1*vSub, 0.0,
        3*hSub, 2*vSub, 0.0,
        4*hSub, 2*vSub, 0.0,
        4*hSub, 1*vSub, 0.0,
    };
    lineLoopBatch.Begin(GL_LINE_LOOP, 4);
    lineLoopBatch.CopyVertexData3f(lineLoop);
    lineLoopBatch.End();
    
    
    // 三角带，如果点是 1, 2, 3, 4, 那么三角形则是 1,2,3 和 2,3,4 以此类推
    GLfloat triangleStrip[] = {
        1*hSub, -1*vSub, 0.0,
        1*hSub, -2*vSub, 0.0,
        2*hSub, -2*vSub, 0.0,
        2*hSub, -1*vSub, 0.0,
    };
    triangleStripBatch.Begin(GL_TRIANGLE_STRIP, 4);
    triangleStripBatch.CopyVertexData3f(triangleStrip);
    triangleStripBatch.End();
    
    // 三角环，与三角带绘制策略不一样，第一个点是所有三角形的公共起点
    // 例如，三角环的顶点是 1,2,3,4,5,6 则构成的三角形是 1,2,3  1,3,4  1,4,5  1,5,6
    // 上诉例子中的1,2,3...表示每一个顶点，他们的顺序会影响最终的绘制效果
    GLfloat triangleLoop[] = {
        3*hSub, -1*vSub, 0.0,
        3*hSub, -2*vSub, 0.0,
        4*hSub, -2*vSub, 0.0,
        4*hSub, -1*vSub, 0.0,
    };
    triangleFanBatch.Begin(GL_TRIANGLE_FAN, 4);
    triangleFanBatch.CopyVertexData3f(triangleLoop);
    triangleFanBatch.End();
    
}

int main(int argc, char * argv[]) {
    
    // 设置当前工作区
    gltSetWorkingDirectory(argv[0]);
    // 初始化GLUT
    glutInit(&argc, argv);
    // 初始化展示模式
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_STENCIL);
    glutInitWindowSize(800, 600);
    glutCreateWindow("图元绘制");
    
    // 视口大小发生改变时的监听函数，类似block回调的策略 changeSize函数指针
    glutReshapeFunc(changeSize);
    // 渲染监听
    glutDisplayFunc(render);
    

    // 初始化glew，如果不初始化，shaderManager将无法使用，会报错
    // 详细介绍看http://glew.sourceforge.net/basic.html
    GLenum err = glewInit();
    if (GLEW_OK != err) {
        printf("glew init fail");
        return 1;
    }
    
    // 配置各种参数，初始化变量
    setup();
    
    glutMainLoop();
    
    return 0;
}
