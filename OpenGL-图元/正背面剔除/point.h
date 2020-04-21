//
//  point.h
//  正背面剔除
//
//  Created by wantexe on 2020/4/21.
//  Copyright © 2020 zhaoguyixia. All rights reserved.
//

#ifndef point_h
#define point_h

#include <stdio.h>
#include "glew.h"

GLfloat value = 0.5;

// 正面
GLfloat cubeFront[] = {
    -value,  value, value,
    -value, -value, value,
     value, -value, value,
     value,  value, value,
};
// 反面
GLfloat cubeBack[] = {
     value,  value, -value,
     value, -value, -value,
    -value, -value, -value,
    -value,  value, -value
};
// 左面
GLfloat cubeLeft[] = {
    -value,  value,  value,
    -value,  value, -value,
    -value, -value, -value,
    -value, -value,  value,
};
// 右面
GLfloat cubeRight[] = {
    value, -value,  value,
    value, -value, -value,
    value,  value, -value,
    value,  value,  value,
};
// 上面
GLfloat cubeTop[] = {
     value, value,  value,
     value, value, -value,
    -value, value, -value,
    -value, value,  value,
};
// 下面
GLfloat cubeBottom[] = {
    -value, -value,  value,
    -value, -value, -value,
     value, -value, -value,
     value, -value,  value,
};

GLfloat color1[] = {1,0,0,1}; 
GLfloat color2[] = {0,1,0,1};
GLfloat color3[] = {0,0,1,1};
GLfloat color4[] = {1,1,0,1};
GLfloat color5[] = {0,1,1,1};
GLfloat color6[] = {1,0,1,1};
#endif /* point_h */
