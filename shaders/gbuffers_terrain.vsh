#version 120

#include "/util.glsl"

attribute vec4 mc_Entity;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 shadowLightPosition;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	float lightDot = dot(normalize(shadowLightPosition), normalize(gl_NormalMatrix * gl_Normal));

	vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
	if (lightDot > 0.1) { // facing sun
		vec4 playerPos = gbufferModelViewInverse * viewPos;
		shadowPos = shadowProjection * (shadowModelView * playerPos);
		float bias = getBias(shadowPos.xyz);
		shadowPos.xyz = distort(shadowPos.xyz) * 0.5 + 0.5;
		// normal bias
		vec4 normal = shadowProjection * vec4(mat3(shadowModelView) * (mat3(gbufferModelViewInverse) * (gl_NormalMatrix * gl_Normal)), 1.0);
		shadowPos.xyz += normal.xyz / normal.w * bias;
	}
	else {
		lmcoord.y *= SHADOW_BRIGHTNESS;
		shadowPos = vec4(0.0);
	}
	shadowPos.w = lightDot;
	gl_Position = gl_ProjectionMatrix * viewPos;
}