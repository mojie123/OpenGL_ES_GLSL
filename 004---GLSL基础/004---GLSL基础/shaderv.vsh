attribute highp vec4 position;
attribute mediump vec2 textCoordinate;
varying lowp vec2 varyTextCoord;
void main(){
    varyTextCoord = textCoordinate;
    gl_Position = position;
}
