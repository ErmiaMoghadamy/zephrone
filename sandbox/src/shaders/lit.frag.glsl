#version 330 core

in vec2 v_texture_coord;
in vec3 v_normal;
in vec3 v_current_pos;

uniform sampler2D u_texture;
uniform vec4 u_light;
uniform vec4 u_light_pos;
uniform vec4 u_camera_pos;

out vec4 out_color;


void main() {
    vec3 light_vec = u_light_pos.xyz - v_current_pos;
    float light_distance = length(light_vec);
    float a = 1.0;
    float b = 0.07;
    float iten = 100.0 / (a * light_distance * light_distance  + b * light_distance + 1.0);
    iten = max(iten, 0.4);

    float ambient = 0.2;

    vec3 normal = normalize(v_normal.xyz);
    vec3 light_dir = normalize(u_light_pos.xyz - v_current_pos.xyz);

    float diffuse = max(dot(normal, light_dir), 0.12);

    float specular_light = 0.5;
    vec3 view_direction = normalize(u_camera_pos.xyz - v_current_pos.xyz);
    vec3 reflection_dir = reflect(-light_dir, normal);
    float specular_amount = pow(max(dot(view_direction, reflection_dir), 0.0), 8);
    float specular = specular_amount * specular_light;


    out_color = texture(u_texture, v_texture_coord) * u_light * (specular + diffuse + ambient);
    out_color.a = 1;
}
