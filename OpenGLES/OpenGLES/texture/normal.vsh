
attribute vec4 position;
attribute vec2 vTextCoor;
varying lowp vec2 varyTextCoord;

void main() {
    vartyTextCoord = vTextCoor;
    gl_Position = position;
}

