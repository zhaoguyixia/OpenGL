
precision mediump float;

varying vec2 varyTextCoord;
uniform sampler2D colorMap;


const float maxRadius = 0.5;

const float angle = 90.0;

void main() {
    
    
    vec2 xy = vec2(varyTextCoord.x-0.5, varyTextCoord.y-0.5);
    
    float r = length(xy);

    float a = atan(xy.y, xy.x) + radians(angle);

    if (r <= maxRadius) {
        xy = varyTextCoord + vec2(r*cos(a), r*sin(a));
    }else{
        xy = varyTextCoord;
    }

    gl_FragColor = texture2D(colorMap, xy);

    
}
