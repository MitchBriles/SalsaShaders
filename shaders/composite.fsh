#version 120

#include "/distort.glsl"

varying vec2 TexCoords;

uniform vec3 sunPosition;
uniform vec3 cameraPosition;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

#include "/lighting.glsl"

void main() {
   // gamma correction
    vec3 albedo = pow(texture2D(colortex0, TexCoords).rgb, vec3(2.2));
    float depth = texture2D(depthtex0, TexCoords).r;

    if (depth == 1.0) {
        gl_FragData[0] = vec4(albedo, 1.0);
        return;
    }
    
    vec3 normal = normalize(texture2D(colortex1, TexCoords).rgb * 2.0 - 1.0);
    vec2 lightmap = texture2D(colortex2, TexCoords).rg;
    vec3 lightmapColor = getLightmapColor(lightmap);
    float NdotL = max(dot(normal, normalize(sunPosition)), 0.0);
    vec3 diffuse = albedo * (lightmapColor + NdotL * getShadow(depth) + ambient);

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(diffuse, 1.0);
}