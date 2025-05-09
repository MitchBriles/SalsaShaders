
/*
const int colortex0Format = RGBA16F;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
*/

const float sunPathRotation = 30.0;
const int shadowMapResolution = 2048;

const float ambient = 0.025;

float adjustLightmapTorch(in float torch) {
    const float K = 2.0;
    const float P = 5.06;
    return K * pow(torch, P);
}

float adjustLightmapSky(in float sky) {
    float sky_2 = sky * sky;
    return sky_2 * sky_2;
}

vec2 adjustLightmap(in vec2 lightmap) {
    vec2 NewLightMap;
    NewLightMap.x = adjustLightmapTorch(lightmap.x);
    NewLightMap.y = adjustLightmapSky(lightmap.y);
    return NewLightMap;
}

vec3 getLightmapColor(in vec2 lightmap) {
    lightmap = adjustLightmap(lightmap);

    const vec3 TorchColor = vec3(1, 0.8, 0.8);
    const vec3 SkyColor = vec3(0.05, 0.15, 0.3);

    vec3 TorchLighting = lightmap.x * TorchColor;
    vec3 SkyLighting = lightmap.y * SkyColor;
    vec3 lightmapLighting = TorchLighting + SkyLighting;
    return lightmapLighting;
}

float visibility(in sampler2D shadowMap, in vec3 sampleCoords) {
    return step(sampleCoords.z, texture2D(shadowMap, sampleCoords.xy).r);
}

vec3 transparentShadow(in vec3 sampleCoords) {
    float shadowVisibility0 = visibility(shadowtex0, sampleCoords);
    float shadowVisibility1 = visibility(shadowtex1, sampleCoords);
    vec4 shadowColor = texture2D(shadowcolor0, sampleCoords.xy);
    vec3 transmittedColor = shadowColor.rgb * (1.0 - shadowColor.a);
    return mix(transmittedColor * shadowVisibility1, vec3(1.0), shadowVisibility0);
}

#define SHADOW_SAMPLES 2
const int shadowSamplesPerSize = 2 * SHADOW_SAMPLES + 1;
const int totalSamples = shadowSamplesPerSize * shadowSamplesPerSize;

vec3 getShadow(float depth) {
    vec3 clipPos = vec3(TexCoords, depth) * 2.0 - 1.0;
    vec4 viewW = gbufferProjectionInverse * vec4(clipPos, 1.0);
    vec3 view = viewW.xyz / viewW.w;
    vec4 world = gbufferModelViewInverse * vec4(view, 1.0);

#ifdef PIXELATED_SHADOW
    // snap to textures
    world.xyz = floor((world.xyz + cameraPosition) * TEXTURE_RESOLUTION + 0.005) / TEXTURE_RESOLUTION.0 - cameraPosition;
#endif // PIXELATED_SHADOW

    // apply blur and such to make soft and clean
    vec4 shadowSpace = shadowProjection * shadowModelView * world;
    shadowSpace.xy = distortPosition(shadowSpace.xy);
    // shadowSpace.z -= 1.0 / 2096.0;
    vec3 sampleCoords = shadowSpace.xyz * 0.5 + 0.5;
    float randomAngle = texture2D(noisetex, TexCoords * 20.0).r * 100.0;
    float cosTheta = cos(randomAngle);
    float sinTheta = sin(randomAngle);
    mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta) / shadowMapResolution;
    vec3 shadowAccum = vec3(0.0);

    for(int x = -SHADOW_SAMPLES; x <= SHADOW_SAMPLES; x++) {
        for(int y = -SHADOW_SAMPLES; y <= SHADOW_SAMPLES; y++) {
            vec2 offset = rotation * vec2(x, y);
            vec3 currentSampleCoordinate = vec3(sampleCoords.xy + offset, sampleCoords.z);
            shadowAccum += transparentShadow(currentSampleCoordinate);
        }
    }

    return shadowAccum / totalSamples;
}
