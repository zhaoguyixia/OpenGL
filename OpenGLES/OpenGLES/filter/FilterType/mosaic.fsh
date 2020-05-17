
varying lowp varyingCoord;
uniform sampler2D colorMap;

void main() {
    
    lowp vec2 coor = vec2(varyingCoord.x, 1.0-varyingCoord.y);
    
    gl_FragColor = texture2D(colorMap, coor);
}
