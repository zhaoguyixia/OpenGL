
varying lowp vec2 varyTextCoord;
// 取色器
uniform sampler2D colorMap;

void main() {
    // 取色器取色，varyTextCoord是从顶点着色器传进来的纹理坐标
    lowp vec2 coor = vec2(varyTextCoord.x, 1.0-varyTextCoord.y);
    
    if (coor.x < 0.5) {
        coor.x = coor.x * 2.0;
    }else{
        coor.x = coor.x * 2.0 - 1.0;
    }
    
    if (coor.y < 0.5) {
        coor.y = coor.y * 2.0;
    }else{
        coor.y = coor.y * 2.0 - 1.0;
    }
    gl_FragColor = texture2D(colorMap, coor);
    gl_FragData
}
