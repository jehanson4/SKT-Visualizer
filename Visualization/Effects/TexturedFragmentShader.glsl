varying lowp vec4 frag_Color;
uniform sampler2D u_texture;

void main(void) {
    gl_FragColor = texture2D(u_texture, gl_PointCoord) * frag_Color;
}
