shader_type canvas_item;
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float noise : hint_range(0, 500.0, 1.0) = 100;
uniform vec4 color : source_color;

void fragment() {
	// Original color of the pixel from the screen
    vec4 pixelColor = texture(screen_texture, UV);
	
	vec2 uv = SCREEN_UV;
    vec4 screen = texture(TEXTURE, uv);
    
    float x = (uv.x + 1.0 ) * (uv.y + 1.0 ) * (TIME * 10.0);
	screen = screen + vec4(mod((mod(x, 13.0) ) * (mod(x, 123.0) ), 0.01) -0.005) * noise;
    COLOR =  pixelColor * (color * screen);
}