// From https://shaders.properties/current/how-to/coordinate_spaces/
vec3 projectAndDivide(mat4 proj, vec3 pos) {
    vec4 homPos = proj * vec4(pos, 1.0);
    return homPos.xyz / homPos.w;
}