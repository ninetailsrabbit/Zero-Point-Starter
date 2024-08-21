/*
This shader subtracts the screen color from 1.0, resulting in an inversion effect where darker areas become lighter and vice versa.
 However, it also performs additional calculations involving the maximum color channel and a small threshold (0.1). 
 These calculations help prevent the shader from completely inverting very bright or dark areas, potentially leading to washed-out or black colors.
*/

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment(){
	
	vec4 color = vec4(texture(SCREEN_TEXTURE, SCREEN_UV).rgb, texture(TEXTURE, UV).a);
	color = vec4((1.0 - color.rgb),  color.a);
	COLOR = color/max(max(max(color.r, color.g), color.b), 0.1);
}