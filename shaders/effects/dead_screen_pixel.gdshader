shader_type canvas_item;

uniform float dead_screen_percent : hint_range(0.0, 1.0);
uniform sampler2D dead_pixel_colors : hint_default_white;
uniform sampler2D noise: hint_default_white;

uniform vec2 resolution = vec2(640, 480);

void fragment() {
	vec2 st = UV;
	st = round(st * resolution) / resolution;
	vec2 rnd_noise = texture(noise, st).xy;

	vec4 col = texture(dead_pixel_colors,vec2(rnd_noise.x, 0.0));
	float alpha = step(1.0-dead_screen_percent, rnd_noise.y);
	col.a = alpha;

	COLOR = col;
}