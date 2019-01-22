varying lowp vec4 frag_Color;
uniform sampler2D tex0;

void main(void) {
    gl_FragColor = texture2D(tex0, gl_PointCoord) * frag_Color;
}
