#version 120

varying vec2 TexCoords;

uniform sampler2D colortex0;

void main() {
    gl_FragColor = vec4(1);
    // /* DRAWBUFFERS:01 */
    // gl_FragData[0] = texture2D(colortex0, TexCoords);
    // gl_FragData[1] = vec4(0, 0, 0, 1);
}