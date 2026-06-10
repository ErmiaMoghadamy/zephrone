#version 330 core

layout (location=0) in vec3 in_position;
layout (location=1) in vec4 in_color;
layout (location=2) in vec2 in_texture_coord;
layout (location=3) in vec3 in_normal;

uniform mat4 u_model;
uniform mat4 u_view;
uniform mat4 u_projection;

out vec4 v_color;
out vec2 v_texture_coord;
out vec2 v_tex_coords;
out vec3 v_normal;
out vec3 v_current_pos;

void main() {
    gl_Position = u_projection * u_view * u_model * vec4(in_position, 1.0);
    v_texture_coord = in_texture_coord;

    mat3 normalMat = transpose(inverse(mat3(u_model)));
    v_normal = normalMat * in_normal;
    v_current_pos = in_position;
}
