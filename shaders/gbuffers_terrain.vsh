#version 120

attribute vec4 mc_Entity;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform mat3 normalMatrix;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;
uniform vec3 eyeCameraPosition;
uniform float frameTimeCounter;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec4 shadowPos;
varying vec3 worldPos;
varying vec3 normal;
varying float lightDot;
varying float fracty;
varying float id;

#include "/distort.glsl"
#include "/util.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	vec3 normalVec = normalize(normalMatrix * gl_Normal);
	lightDot = dot(normalize(shadowLightPosition), normalize(gl_NormalMatrix * gl_Normal));
	#ifdef EXCLUDE_FOLIAGE
		//when EXCLUDE_FOLIAGE is enabled, act as if foliage is always facing towards the sun.
		//in other words, don't darken the back side of it unless something else is casting a shadow on it.
		if (mc_Entity.x == 10000.0) lightDot = 1.0;
	#endif

	vec3 wavy_offset = vec3(0.0);
	if (mc_Entity.x == 10001.0) {
		wavy_offset.x += 0.01 * sin(frameTimeCounter + gl_Vertex.x + cameraPosition.x);
		wavy_offset.x += 0.04 * sin(0.52 * (frameTimeCounter + gl_Vertex.x + cameraPosition.x));
		wavy_offset.y += 0.02 * sin(0.91 * (frameTimeCounter + gl_Vertex.y + cameraPosition.y));
		wavy_offset.y += 0.015 * sin(0.67 * (frameTimeCounter + gl_Vertex.y + cameraPosition.y));
		wavy_offset.z += 0.01 * sin(0.85 * (frameTimeCounter + gl_Vertex.z + cameraPosition.z));
		wavy_offset.z += 0.022 * sin(0.71 * (frameTimeCounter + gl_Vertex.z + cameraPosition.z));
	}

	if (mc_Entity.x == 10000.0) {
		wavy_offset.x += 0.051 * sin(frameTimeCounter + gl_Vertex.x + cameraPosition.x);
		wavy_offset.x += 0.04 * sin(0.44 * (frameTimeCounter + gl_Vertex.x + cameraPosition.x));
		wavy_offset.z += 0.03 * sin(0.85 * (frameTimeCounter + gl_Vertex.z + cameraPosition.z));
		wavy_offset.z += 0.027 * sin(0.71 * (frameTimeCounter + gl_Vertex.z + cameraPosition.z));
		// wavy_offset.x *= ;
	}

	id = mc_Entity.x;

	vec3 please = floor((gl_Vertex.xyz + cameraPosition) * 16.0 + 0.01) / 16.0 - cameraPosition;
	vec4 viewPos = gl_ModelViewMatrix * (vec4(please + wavy_offset, 1.0));
	if (lightDot > 0.0) { //vertex is facing towards the sun
		vec4 playerPos = gbufferModelViewInverse * viewPos;

		vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos.xyz;
		vec3 worldPos = eyePlayerPos + cameraPosition + gbufferModelViewInverse[3].xyz;
		fracty = fract(((worldPos.y)));
		// worldPos.x = floor(worldPos.x);
		// worldPos.x = floor(worldPos.x) + 0.1;

		playerPos.xyz = worldPos - cameraPosition;
		vec4 shadowViewPos = shadowModelView * playerPos;
		shadowPos = shadowProjection * shadowViewPos; //convert to shadow ndc space.
		float bias = computeBias(shadowPos.xyz);
		shadowPos.xyz = distort(shadowPos.xyz); //apply shadow distortion
		shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
		//apply shadow bias.
		#ifdef NORMAL_BIAS
			//we are allowed to project the normal because shadowProjection is purely a scalar matrix.
			//a faster way to apply the same operation would be to multiply by shadowProjection[0][0].
			vec4 normal = shadowProjection * vec4(mat3(shadowModelView) * (mat3(gbufferModelViewInverse) * (normalMatrix * gl_Normal)), 1.0);
			shadowPos.xyz += normal.xyz / normal.w * bias;
		#else
			shadowPos.z -= bias / abs(lightDot);
		#endif

	}
	else { //vertex is facing away from the sun
		lmcoord.y *= SHADOW_BRIGHTNESS; //guaranteed to be in shadows. reduce light level immediately.
		shadowPos = vec4(0.0); //mark that this vertex does not need to check the shadow map.
	}
	shadowPos.w = lightDot;
	gl_Position = gl_ProjectionMatrix * viewPos;
}