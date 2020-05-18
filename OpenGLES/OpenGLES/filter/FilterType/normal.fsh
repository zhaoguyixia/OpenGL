
varying lowp vec2 varyTextCoord;
// 取色器
uniform sampler2D colorMap;

void main() {
    // 取色器取色，varyTextCoord是从顶点着色器传进来的纹理坐标
    lowp vec2 coor = vec2(varyTextCoord.x, 1.0-varyTextCoord.y);
    gl_FragColor = texture2D(colorMap, coor);
}
