#version 120

#include "/distort.glsl"

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

varying vec2 TexCoords;
varying vec4 Color;

uniform float frameTimeCounter;
uniform vec3 cameraPosition;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;


#include "/wavy.glsl"

void main() {
    vec4 position = shadowModelViewInverse * shadowProjectionInverse * ftransform();

	vec3 worldPos = position.xyz + cameraPosition.xyz;
	
	float istopv = gl_MultiTexCoord0.t < mc_midTexCoord.t ? 1.0 : 0.0;
	position.xyz = WavingBlock(position.xyz, istopv);
	
	gl_Position = shadowProjection * shadowModelView * position;
    gl_Position.xy = distortPosition(gl_Position.xy);
    TexCoords = gl_MultiTexCoord0.st;
    Color = gl_Color;
}