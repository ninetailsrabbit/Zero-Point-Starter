shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap_anisotropic;

uniform float blur_intensity: hint_range(0.0, 6.0, 0.01);
uniform float opacity: hint_range(0.0, 1.0, 0.01);

void fragment() {
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	vec4 screen_color_blurred = texture(screen_texture, SCREEN_UV, blur_intensity);
	screen_color = max(screen_color, screen_color_blurred * opacity);
	COLOR = screen_color;
}
