/*
Color mapping, in this context, refers to the process of transforming the original color values of the sprite texture based on user-defined target colors.
 This shader essentially takes each channel of the sprite color (red, green, blue) and replaces it with a color specified by the corresponding mapping vector (red_mapping, green_mapping, blue_mapping).
 The intensity uniform allows for control over how strongly this replacement occurs.

This shader can be used for various artistic effects and image processing tasks:

Color Grading: By adjusting the red_mapping, green_mapping, and blue_mapping vectors, you can achieve different color grading effects, like creating a warmer or cooler tone for the entire sprite.
Selective Color Correction: You can use different mapping colors for each channel to achieve a selective color correction effect. For example, you could emphasize the red
*/
shader_type canvas_item;

uniform float intensity = 1.0;
uniform vec3 red_mapping : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 green_mapping : source_color = vec3(0.0, 1.0, 0.0);
uniform vec3 blue_mapping : source_color = vec3(0.0, 0.0, 1.0);

void fragment() {
	vec4 sprite_color = texture(TEXTURE, UV);
	vec3 new_color = vec3(0, 0, 0);
	new_color += min(sprite_color.r*red_mapping, 1.0);
	new_color += min(sprite_color.g*green_mapping, 1.0);
	new_color += min(sprite_color.b*blue_mapping, 1.0);
	COLOR = vec4(mix(sprite_color.rgb, new_color, intensity), sprite_color.a);
}
