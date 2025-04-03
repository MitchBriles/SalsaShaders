#version 120

#define DRAW_SHADOW_MAP gcolor

uniform float frameTimeCounter;
uniform sampler2D gcolor;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

varying vec2 texcoord;

void main() {
	vec3 color = texture2D(DRAW_SHADOW_MAP, texcoord).rgb;

	gl_FragData[0] = vec4(color, 1.0);
}