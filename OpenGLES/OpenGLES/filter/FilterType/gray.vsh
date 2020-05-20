

attribute vec4 position;
attribute vec2 vTextCoor;

varying vec2 varyTextCoord;

void main() {
    
    varyTextCoord = vTextCoor;
    gl_Position = position;
    
}
