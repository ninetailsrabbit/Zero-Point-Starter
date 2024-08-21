/*
https://forum.godotengine.org/t/color-blindness-simulator-shader/49890

     MODES
0- No modification
1- protanopia
2- deuteranopia
3- tritanopia
4- achromatopsia

Useful to simulate accesibility issues for color blind people and increase the accessibility for your game

Apply the shader material to a mesh and look through it
*/

shader_type spatial;
render_mode unshaded;
uniform sampler2D SCREEN_TEXTURE:hint_screen_texture;
global uniform int daltonism : hint_range(0,4) = 0;

const mat4 prota = mat4(
	vec4(0.170556992,0.170556991,-0.004517144,0.0),
	vec4(0.829443014,0.829443008,0.004517144 ,0.0),
 	vec4(0.0,0.0,1.0,0.0 ),
	vec4(0.0,0.0,0.0,1.0)
);
const mat4 deute = mat4(
	vec4(0.33066007,0.33066007,-0.02785538,0.0),
	vec4(0.66933993,0.66933993,0.02785538,0.0),
 	vec4(0.0,0.0,1.0,0.0),
	vec4(0.0,0.0,0.0,1.0)
);
const mat4 trita = mat4(
	vec4(1, 0, 0,0.0),
	vec4(0.1273,0.8739,0.8739,0.0),
 	vec4(-0.1273, 0.1260, 0.1260,0.0),
	vec4(0.0,0.0,0.0,1.0)
);
 const mat4 achroma = mat4(
	vec4(0.299, 0.587 ,  0.114,0.0),
	vec4(0.299, 0.587 ,  0.114,0.0),
 	vec4(0.299, 0.587 ,  0.114,0.0),
	vec4(0.0,0.0,0.0,1.0)
);

void fragment() {
	vec4 source =texture(SCREEN_TEXTURE,SCREEN_UV).rgba;
	vec4 target;
	switch(daltonism){
		case 0:
			target=source;   
			break;
		case 1:
			target=prota*source;	
			break;
		case 2:
			target=deute*source;	
			break;
		case 3:
			target=trita*source;	
			break;
		case 4:
			target=source*achroma;	
			break;
	}
	ALBEDO = target.rgb;
}