#include "/config.glsl"

vec2 distortPosition(in vec2 position) {
#ifdef SHADOW_DISTORTION
    float centerDistance = length(position);
    float distortionFactor = mix(1.0, centerDistance, 0.9);
    return position / distortionFactor;
#else
    return position;
#endif
}