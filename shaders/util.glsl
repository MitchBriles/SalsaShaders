#define SHADOW_BIAS 0.5
#define SHADOW_BRIGHTNESS 0.75
#define SHADOW_DISTORT_FACTOR 0.1

const int shadowMapResolution = 1048;

vec3 distort(vec3 pos) {
    float factor = length(pos.xy) + SHADOW_DISTORT_FACTOR;
    return vec3(pos.xy / factor, pos.z * 0.1);
}

// returns bias/d'(p) where d is the distrotion function
float getBias(vec3 pos) {
    float numerator = length(pos.xy) + SHADOW_DISTORT_FACTOR;
    numerator *= numerator;
    return SHADOW_BIAS / shadowMapResolution * numerator / SHADOW_DISTORT_FACTOR;
}