#version 120

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 shadowLightPosition;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 shadowPos;

#include "/util.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
	vec4 playerPos = gbufferModelViewInverse * viewPos;
	shadowPos = (shadowProjection * shadowModelView * playerPos).xyz;
	float bias = getBias(shadowPos);
	shadowPos = distort(shadowPos); //apply shadow distortion.
	shadowPos = shadowPos * 0.5 + 0.5; //convert from shadow ndc space to shadow screen space.
	//shadowPos.z -= bias; //apply shadow bias.
	vec4 normal = shadowProjection * vec4(mat3(shadowModelView) * (mat3(gbufferModelViewInverse) * (gl_NormalMatrix * gl_Normal)), 1.0);
	shadowPos.xyz += normal.xyz / normal.w * bias;

	gl_Position = gl_ProjectionMatrix * viewPos;
}