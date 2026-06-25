#version 330 core

// FIX: Changed from v_tex_coords to match your vertex shader output name
in vec2 v_texture_coord;
in vec3 v_normal;
in vec3 v_current_pos; // This is in local space from your vertex shader

out vec4 out_color;

uniform sampler2D u_texture;
uniform vec4 u_light;
uniform vec4 u_light_pos;
uniform vec4 u_camera_pos;
uniform mat4 u_model; // FIX: Added u_model to convert local space to world space here

void main() {
    // FIX: Transform local vertex position into true World Space before doing lighting math
    vec3 world_pos = (u_model * vec4(v_current_pos, 1.0)).xyz;

    float ambient = 0.2;

    vec3 normal = normalize(v_normal);

    // FIX: Using world_pos instead of v_current_pos
    vec3 light_dir = normalize(u_light_pos.xyz - world_pos);
    float diffuse = max(dot(normal, light_dir), 0.0);

    float specular_light = 0.5;

    // FIX: Using world_pos instead of v_current_pos
    vec3 view_direction = normalize(u_camera_pos.xyz - world_pos);
    vec3 reflect_direction = reflect(-light_dir, normal);
    float specular_amount = pow(max(dot(view_direction, reflect_direction), 0.0), 32.0);
    float specular = specular_light * specular_amount;

    // FIX: Using updated v_texture_coord variable name
    vec4 tex_color = texture(u_texture, v_texture_coord);

    out_color = tex_color * u_light * (ambient + diffuse + specular);
    out_color.a = tex_color.a;
}
