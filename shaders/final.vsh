#version 120

varying vec2 TexCoords;

const int noiseTextureResolution = 512;

void main() {
   gl_Position = ftransform();
   TexCoords = gl_MultiTexCoord0.st;
}
