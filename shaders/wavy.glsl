#include "/config.glsl"

#ifdef WAVING_PLANTS
vec3 CalcWave(vec3 pos, float density, float speed, vec2 mult) {
    pos = pos * density + frameTimeCounter * speed;
    vec3 wave = vec3(0.0);
    wave.x += 0.18 * sin(pos.x);
	wave.x += 0.22 * sin(1.44 * pos.x);
	wave.x += 0.17 * sin(3 * pos.x);
	wave.x += 0.1 * sin(1 * pos.x);
	wave.y += 0.15 * sin(0.5 * pos.x);
	wave.y += 0.1 * sin(1 * pos.x);
	wave.y += 0.2 * sin(0.91 * pos.y);
	wave.y += 0.15 * sin(0.67 * pos.y);
	wave.y += 0.21 * sin(0.75 * pos.z);
	wave.y += 0.17 * sin(1.21 * pos.z);
	wave.z += 0.11 * sin(0.85 * pos.z);
	wave.z += 0.27 * sin(1.21 * pos.z);
	wave.z += 0.3 * sin(0.75 * pos.z);
	wave.z += 0.13 * sin(1.51 * pos.z);
    return wave * vec3(mult, mult.x);
}

vec3 WavingBlock(vec3 position, float istopv) {
    vec3 wave = vec3(0.0);
    vec3 worldpos = position + cameraPosition;
    
    switch (int(mc_Entity.x)) {
        case 10000:
            if (istopv > 0.9)
                wave += CalcWave(worldpos, 0.35, 1.0, vec2(0.25, 0.06));
            break;
        case 10001:
            wave += CalcWave(worldpos, 0.25, 1.0, vec2(0.08, 0.08));
            break;
        case 10002:
            if ((istopv > 0.9 || fract(worldpos.y + 0.0675) > 0.01))
                wave += CalcWave(worldpos, 0.1, 1.0, vec2(0.15, 0.06));
            break;
        case 10003:
        case 10004:
            if ((mc_Entity.x == 10003.0 && (istopv > 0.9 || fract(worldpos.y + 0.005) > 0.01)) || mc_Entity.x == 10004.0)
                wave += CalcWave(worldpos, 0.35, 1.15, vec2(0.15, 0.06));
            break;
        case 10005:
            break;
        default: return position;
    }

    position += wave;

    return position;
}
#else
vec3 WavingBlock(vec3 position, float istopv) {
    return position;
}
#endif