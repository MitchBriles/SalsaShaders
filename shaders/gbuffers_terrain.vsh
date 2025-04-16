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
//varying vec3 Pos;

vec3 CalcMove(vec3 pos, float density, float speed, vec2 mult) {
    pos = pos * density + frameTimeCounter * speed;
    vec3 wave = vec3(0.0);
    wave.x += 0.21 * sin(pos.x);
	wave.x += 0.27 * sin(1.44 * pos.x);
	wave.x += 0.17 * sin(3 * pos.x);
	wave.x += 0.1 * sin(1 * pos.x);
	wave.y += 0.2 * sin(0.91 * (frameTimeCounter + gl_Vertex.y));
	wave.y += 0.15 * sin(0.67 * (frameTimeCounter + gl_Vertex.y));
	wave.z += 0.11 * sin(0.85 * pos.z);
	wave.z += 0.27 * sin(1.21 * pos.z);
	wave.z += 0.3 * sin(0.75 * pos.z);
	wave.z += 0.13 * sin(1.51 * pos.z);
    return wave * vec3(mult, mult.x);
}

vec3 WavingBlocks(vec3 position, float istopv) {
    vec3 wave = vec3(0.0);
    vec3 worldpos = position + cameraPosition;
    
    switch (int(mc_Entity.x)) {
        case 10000:
            if ((istopv > 0.9 || fract(worldpos.y + 0.0675) > 0.01))
                wave += CalcMove(worldpos, 0.1, 1.0, vec2(0.15, 0.06));
            break;
        case 10001:
            wave += CalcMove(worldpos, 0.25, 1.0, vec2(0.08, 0.08));
            break;
        default: return position;
    }


    wave.z *= 1.0 - Normal.z;

    position += wave;

    return position;
}

void main() {
    Normal = gl_NormalMatrix * gl_Normal;

    vec3 offset = vec3(0.0);

    if (mc_Entity.x == 10000.0) {
		offset.x += 0.051 * sin(frameTimeCounter + gl_Vertex.x);
		offset.x += 0.04 * sin(0.44 * (frameTimeCounter + gl_Vertex.x));
		offset.z += 0.03 * sin(0.85 * (frameTimeCounter + gl_Vertex.z));
		offset.z += 0.027 * sin(0.71 * (frameTimeCounter + gl_Vertex.z));
	}

    if (mc_Entity.x == 10001.0) {
        offset.x += 0.01 * sin(frameTimeCounter + gl_Vertex.x);
		offset.x += 0.04 * sin(0.52 * (frameTimeCounter + gl_Vertex.x));
		offset.y += 0.02 * sin(0.91 * (frameTimeCounter + gl_Vertex.y));
		offset.y += 0.015 * sin(0.67 * (frameTimeCounter + gl_Vertex.y));
		offset.z += 0.01 * sin(0.85 * (frameTimeCounter + gl_Vertex.z));
		offset.z += 0.022 * sin(0.71 * (frameTimeCounter + gl_Vertex.z));
    }

    // offset.x *= 

    // vec3 viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;

    // vec3 playerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
    // vec3 worldPos = playerPos + cameraPosition;
    // // offset *= fract(worldPos.y);
    // worldPos += offset;
    // playerPos = worldPos - cameraPosition;
    // viewPos = (gbufferModelView * vec4(playerPos, 1.0)).xyz;

    // vec4 clipPos = (gl_ProjectionMatrix * vec4(viewPos, 1.0));
    // gl_Position = clipPos;


	vec4 position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;


	float istopv = gl_MultiTexCoord0.t < mc_midTexCoord.t ? 1.0 : 0.0;

    //if (mc_Entity.x == 10000.0)
        //position.x += fract(position.y + cameraPosition.y + 0.0675);//offset * fract(position.y + cameraPosition.y);
	position.xyz = WavingBlocks(position.xyz, istopv);


	gl_Position = gl_ProjectionMatrix * gbufferModelView * position;

    TexCoords = gl_MultiTexCoord0.st;
    LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    LightmapCoords = (LightmapCoords * 33.05 / 32.0) - (1.05 / 32.0);
    Color = gl_Color;
}