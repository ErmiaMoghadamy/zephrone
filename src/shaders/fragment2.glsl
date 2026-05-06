#version 330 core

varying vec3 v_color;
out vec4 out_color;

void main() {
    out_color = vec4(sin(v_color * 10), 1.0);

    out_color.xyz *= 3;
    out_color.xyz = floor(out_color.xyz);
    out_color.xyz /= 3;

    if (out_color.x < 0.001 && out_color.y < 0.001 && out_color.z < 0.001) {
        out_color = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
