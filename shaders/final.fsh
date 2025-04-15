#version 120

varying vec2 TexCoords;

uniform sampler2D colortex0;

void main() {
   gl_FragColor = vec4(pow(texture2D(colortex0, TexCoords).rgb, vec3(1.0 / 2.2)), 1.0);
}