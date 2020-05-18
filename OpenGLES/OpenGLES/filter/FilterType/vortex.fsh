
precision mediump float;

uniform float yinzi;
varying vec2 varyTextCoord;
uniform sampler2D colorMap;
// 最大半径，在这个半径内都会发生旋转
const float maxRadius = 0.5;
// 偏移角度
const float angle = 90.0;

void main() {
    
    vec2 xy = vec2(varyTextCoord.x-0.5, varyTextCoord.y-0.5);
    
    float r = length(xy);
    
    // 将平面坐标系转成极坐标系
    // x = r*cos(a)  y = r*sin(a)
    // tana = y / x
    // a = atan(y/x) = atan(y, x) 定义域(-00, +00)，可取
    // a = acos(x/r) = asin(y/x) 定义域(-1, 1)，不可取
    // float a = atan(xy.y , xy.x) + radians(angle);
    // float a = asin(xy.x/r)
    // float a = acos(xy.y/r)
    
    if (r <= maxRadius) {
        float sub = 1.0 - yinzi * r * r;
        float a = atan(xy.y , xy.x) + radians(angle) * 2.0 * sub;
        xy = vec2(0.5, 0.5) + vec2(r*cos(a), r*sin(a));
    }else{
        xy = varyTextCoord;
    }

    gl_FragColor = texture2D(colorMap, xy);

}
