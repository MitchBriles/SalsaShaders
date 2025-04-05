#version 120

#include "/util.glsl"

uniform sampler2D lightmap;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 shadowPos;

const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	vec2 lm = lmcoord;

	float delta = 0.5 / shadowMapResolution;
	if (texture2D(shadowtex0, shadowPos.xy		   			).r < shadowPos.z //&&
		// texture2D(shadowtex0, shadowPos.xy + vec2( delta, 0)).r < shadowPos.z &&
		// texture2D(shadowtex0, shadowPos.xy + vec2( 0, delta)).r < shadowPos.z &&
		// texture2D(shadowtex0, shadowPos.xy + vec2(-delta, 0)).r < shadowPos.z &&
		// texture2D(shadowtex0, shadowPos.xy + vec2(0, -delta)).r < shadowPos.z
		) {
		lm.y *= SHADOW_BRIGHTNESS;
	}
	else {
		lm.y = 31.0 / 32.0;
	}
	color *= texture2D(lightmap, lm);

	gl_FragData[0] = color;
}