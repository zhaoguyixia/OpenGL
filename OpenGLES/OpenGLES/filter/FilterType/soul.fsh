
precision mediump float;

uniform sampler2D colorMap;

varying vec2 varyTextCoord;

void main() {
    
    vec2 coor = vec2(varyTextCoord.x, 1.0-varyTextCoord.y);
    
    gl_FragColor = texture2D(colorMap, coor);
    
}
