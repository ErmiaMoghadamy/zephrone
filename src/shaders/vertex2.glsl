#version 330 core

layout(location = 0) in vec3 in_position;
layout(location = 1) in vec3 in_color;

varying vec3 v_color;

void main() {
    gl_Position = vec4(in_position * 0.5, 1.0);
    v_color = in_color;
}
