shader_type spatial;
uniform vec4 color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D main_tex;
uniform sampler2D normal_tex;
uniform float glossiness = 0.5;
uniform float metallic = 0.0;
uniform float scroll_x_speed = 0.0;
uniform float scroll_y_speed = -0.4;
uniform sampler2D disp_tex;
uniform float displacement_amount = 0.5;
uniform float sin_amplitude = 0.5;
uniform float sin_frequency = 0.0;
uniform float sin_speed = 0.0;

void vertex() {
	vec4 displacement = texture(disp_tex, UV);
	float d = displacement.r * displacement_amount;
	VERTEX.xyz += NORMAL * (sin((VERTEX.x + TIME * sin_speed) * sin_frequency) + cos((VERTEX.z + TIME * sin_speed) * sin_amplitude)) * d;
	UV.x += scroll_x_speed * TIME;
	UV.y += scroll_y_speed * TIME;
}
void fragment() {
// Called for every pixel the material is visible on.
	vec4 albedo_tex = texture(main_tex, UV);
	ALBEDO = albedo_tex.rgb * color.rgb;
	ALPHA = albedo_tex.a * color.a;
	vec3 normal_map = texture(normal_tex, UV).rgb;
	NORMAL = normalize((normal_map * 2.0) - 1.0);
	ROUGHNESS = 1.0 - glossiness;
	METALLIC = metallic;
}
void light() {
}