#version 120

#include "/distort.glsl"

varying vec2 TexCoords;

uniform vec3 sunPosition;
uniform vec3 cameraPosition;
uniform vec3 fogColor;
uniform float far;
uniform int blockEntityId;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
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

uniform float weight[17] = float[] (0.227027, 0.2189189, 0.2108108, 0.2027027, 0.1945946, 0.17635135, 0.1581081, 0.13986485, 0.1216216, 0.1047297, 0.0878378, 0.0709459, 0.054054, 0.0445945, 0.035135, 0.0256755, 0.016216);

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
  vec4 homPos = projectionMatrix * vec4(position, 1.0);
  return homPos.xyz / homPos.w;
}

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

    // bloom
    vec3 bloom = vec3(0);
#ifdef BLOOM
    vec2 tex_offset = 1.0 / textureSize(colortex3, 0);
    bloom = texture(colortex3, TexCoords).rgb * weight[0];
    int n = 17;
    
    // verticle blur
    for(int i = 1; i < n; ++i)
    {
        bloom += texture(colortex3, TexCoords + vec2(0.0, tex_offset.y * i)).rgb * weight[i];
        bloom += texture(colortex3, TexCoords - vec2(0.0, tex_offset.y * i)).rgb * weight[i];
    }

    // horizontal blur
    for(int i = 1; i < n; ++i)
    {
        bloom += texture(colortex3, TexCoords + vec2(tex_offset.x * i, 0.0)).rgb * weight[i];
        bloom += texture(colortex3, TexCoords - vec2(tex_offset.x * i, 0.0)).rgb * weight[i];
    }
#endif

    float NdotL = max(dot(normal, normalize(sunPosition)), 0.0);
    vec3 diffuse = albedo * (lightmapColor + bloom + NdotL * getShadow(depth) + ambient);

    vec3 NDCPos = vec3(TexCoords, depth) * 2.0 - 1.0;
    vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
    // float dist = length(viewPos);
    // diffuse = mix(diffuse, pow(fogColor, vec3(2.2)), dist/(far));

    float dist = length(viewPos) / far;
    float fogFactor = exp(-FOG_DENSITY * (1.0 - dist));

    diffuse = mix(diffuse, fogColor, clamp(fogFactor, 0.0, 1.0));

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(diffuse, 1.0);
}