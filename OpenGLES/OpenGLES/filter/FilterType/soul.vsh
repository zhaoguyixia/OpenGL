
attribute vec4 position;
attribute vec2 vTextCoord;

varying vec2 varyTextCoord;

void main() {
    varyTextCoord = vTextCoord;
    gl_Position = position;
}
