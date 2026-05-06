#version 330 core

layout(location = 0) in vec3 in_position;
layout(location = 1) in vec2 in_uv;

varying vec2 v_UV;

uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;

void main() {
    gl_Position = (uProjection * uView * uModel) * vec4(in_position, 1.0);
    v_UV = in_uv;
}
