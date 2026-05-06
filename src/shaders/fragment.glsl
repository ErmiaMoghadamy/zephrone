#version 330 core

varying vec2 v_UV;

out vec4 color;

uniform sampler2D uTex;

void main() {
    // color = vec4(vColor, 1.0);
    color = texture(uTex, v_UV);
}
