#version 330 core

in vec2 v_texture_coords;

uniform sampler2D u_texture;

out vec4 out_color;

void main() {
    out_color = texture(u_texture, v_texture_coords);
}
