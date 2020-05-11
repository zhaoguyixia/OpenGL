
precision mediump float;

varying vec2 varyTextCoord;
uniform sampler2D colorMap;


const float maxRadius = 0.5;

const float angle = 80.0;

void main() {
    
    
    vec2 xy = vec2(varyTextCoord.x-0.5, varyTextCoord.y-0.5);
    
    float r = length(xy);

    float a = atan(xy.x, xy.y) + radians(angle);

    if (r <= maxRadius) {
        // 重新计算
        xy = varyTextCoord + vec2(cos(a), sin(a));
    }else{
        xy = varyTextCoord;
    }

    gl_FragColor = texture2D(colorMap, xy);

    
}
