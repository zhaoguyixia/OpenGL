
attribute vec4 position;
attribute vec2 vTextcoord;

varying lowp varyingCoord;

void main() {
    varyingCoord = vTextcoord;
    gl_Position = position;
}
