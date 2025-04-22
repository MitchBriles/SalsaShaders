#version 120

in float blockID;

varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;

uniform sampler2D texture;

vec2 getOreLight(vec4 albedo) {
    switch (int(blockID)) {
        case 10101: // diamond
            if (texture2D(texture, TexCoords).b > 0.8) {
                return vec2(dot(texture2D(texture, TexCoords).rgb, vec3(0.4126, 0.5152, 0.322)), 0);
            }
            return LightmapCoords;
            break;
        default:
            return LightmapCoords;
    }
}

vec4 getBright(vec4 albedo) {
    float brightness = dot(texture2D(texture, TexCoords).rgb, vec3(0.4126, 0.5152, 0.322));   
    switch (int(blockID)) {
        case 10100: // emmissives
            if (brightness > 1.0) {
                return vec4(texture2D(texture, TexCoords).rgb, 1.0);
            }
            break;
        default:
            break;
    }
    return vec4(0.0, 0.0, 0.0, 1.0);
}

void main() {
    vec4 albedo = texture2D(texture, TexCoords) * Color;
    vec4 BrightColor = getBright(albedo);
    // vec4 BrightColor = vec4(albedo.rgb * brightness, 1.0);

    /* DRAWBUFFERS:0123 */
    gl_FragData[0] = albedo;
    gl_FragData[1] = vec4(Normal * 0.5 + 0.5, 1.0);
    gl_FragData[2] = vec4(getOreLight(albedo), 0.0, 1.0);
    gl_FragData[3] = BrightColor;
}