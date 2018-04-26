varying lowp vec4 frag_Color;
uniform sampler2D u_Texture;

void main(void) {
    gl_FragColor = texture2D(u_Texture, gl_PointCoord) * frag_Color;
}
