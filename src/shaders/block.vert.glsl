#version 330 core

layout(location = 0) in vec3 in_position;
layout(location = 1) in vec4 in_color;
layout(location = 2) in vec2 in_texture_coords;
layout(location = 3) in vec3 in_normal;

out vec2 v_tex_coords;
out vec3 v_normal;
out vec3 v_current_pos;

uniform mat4 u_model;
uniform mat4 u_view;
uniform mat4 u_projection;

void main() {
    gl_Position = u_projection * u_view * u_model * vec4(in_position, 1.0);

    v_tex_coords = in_texture_coords;

    mat3 normalMat = transpose(inverse(mat3(u_model)));
    v_normal = normalMat * in_normal;
    v_current_pos = vec3(u_model * vec4(in_position, 1.0));
}
