
precision mediump float;
// 放大因子
uniform float scale;

uniform sampler2D colorMap;

varying vec2 varyTextCoord;

void main() {
    
    vec2 coor = vec2(varyTextCoord.x, 1.0-varyTextCoord.y);
    
    // 原图
    vec4 originColor = texture2D(colorMap, coor);
    
    // 放大的图
    float x = coor.x - 0.5;
    float y = coor.y - 0.5;
    coor = vec2(coor.x - x * scale, coor.y - y * scale);
    
    float mask = 0.3;
    
    vec4 scaleColor = texture2D(colorMap, coor);
    
//    vec4 endColor = vec4(originColor.r * (1.0-mask) + (scaleColor.r+0.5) * mask,
//                         originColor.g * (1.0-mask) + scaleColor.g * mask,
//                         originColor.b * (1.0-mask) + scaleColor.b * mask,
//                         originColor.a * (1.0-mask) + scaleColor.a * mask);
    
    vec4 endColor = originColor * (1.0-mask) + scaleColor * mask;
    
    gl_FragColor = endColor;
    
}
