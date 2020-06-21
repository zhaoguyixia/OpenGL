precision mediump float;
varying vec2 varyTextCoord;

uniform sampler2D colorMap;

void main() {
    /*
     任何颜色都有红、绿、蓝三原色组成，假如原来某点的颜色为RGB(R，G，B)，那么，我们可以通过下面几种方法，将其转换为灰度：
     1.浮点算法：Gray=R*0.3+G*0.59+B*0.11
     2.整数方法：Gray=(R*30+G*59+B*11)/100
     3.移位方法：Gray =(R*76+G*151+B*28)>>8;
     4.平均值法：Gray=(R+G+B)/3;
     5.仅取绿色：Gray=G；
     */
    vec2 coor = vec2(varyTextCoord.x, 1.0-varyTextCoord.y);
//    coor = varyTextCoord;
    vec4 source = texture2D(colorMap, coor);
    
    float r = (source.r + source.g + source.b)/3.0;
    
    r = source.r*0.3 + source.g*0.59 + source.b*0.11;
    
    r = dot(source, vec4(0.3, 0.59, 0.11, 0.0));
    
    vec4 color = vec4(r, r, r, source.a);
    
    gl_FragColor = color;
    
}
