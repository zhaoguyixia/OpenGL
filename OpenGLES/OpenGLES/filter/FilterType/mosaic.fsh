
precision mediump float;

varying vec2 varyTextCoord;
uniform sampler2D colorMap;
// 几行
uniform int rowCount;
// 几列
//uniform int clownCount;

void main() {
    
    int clownCount = rowCount;
    
    vec2 coor = vec2(varyTextCoord.x, 1.0-varyTextCoord.y);
    
    float row = 1.0/float(clownCount);
    float clown = 1.0/float(rowCount);
    
    float x = coor.x;
    float y = coor.y;
    
    float currentX = row * float(int(x/row));
    float currentY = clown * float(int(y/clown));
    
    gl_FragColor = texture2D(colorMap, vec2(currentX, currentY));
}
