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
varying vec4 shadowPos;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	vec2 lm = lmcoord;
	if (shadowPos.w > 0.0) {
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
			lm.y = mix(31.0 / 32.0 * SHADOW_BRIGHTNESS, 31.0 / 32.0, sqrt(shadowPos.w));
		}
	}
	color *= texture2D(lightmap, lm);

	gl_FragData[0] = color;
}