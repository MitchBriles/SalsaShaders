#version 120 compatibility

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

uniform vec3 cameraPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform float frameTimeCounter;

varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;

#include "/wavy.glsl"

void main() {
    Normal = gl_NormalMatrix * gl_Normal;

	vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;


	float istopv = gl_MultiTexCoord0.t < mc_midTexCoord.t ? 1.0 : 0.0;

    position.xyz = WavingBlock(position.xyz, istopv);


	gl_Position = gl_ProjectionMatrix * gbufferModelView * position;

    TexCoords = gl_MultiTexCoord0.st;
    LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    LightmapCoords = (LightmapCoords * 33.05 / 32.0) - (1.05 / 32.0);
    Color = gl_Color;
}