#version 330 core

in vec2 v_tex_coords;
in vec3 v_normal;
in vec3 v_current_pos;

out vec4 out_color;

uniform sampler2D u_texture;
uniform vec4 u_light;
uniform vec4 u_light_pos;
uniform vec4 u_camera_pos;

void main() {
    float ambient = 0.2;

    vec3 normal = normalize(v_normal);
    vec3 light_dir = normalize(vec3(u_light_pos) - v_current_pos);
    float diffuse = max(dot(normal, light_dir), 0.0);

    float specular_light = 0.5;
    vec3 view_direction = normalize(vec3(u_camera_pos) - v_current_pos);
    vec3 reflect_direction = reflect(-light_dir, normal);
    float specular_amount = pow(max(dot(view_direction, reflect_direction), 0.0), 32.0);
    float specular = specular_light * specular_amount;

    out_color = texture(u_texture, v_tex_coords) * (u_light) * (ambient + diffuse + specular);
    out_color.a = texture(u_texture, v_tex_coords).a;
}
