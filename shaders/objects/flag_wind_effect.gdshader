/*
This shader applies a wind effect to a mesh, 
very useful if you want to achieve wind effects on flags, curtains or other elements that are light sized.
*/
shader_type spatial;
render_mode cull_disabled, blend_mix;
uniform float wind_speed;

uniform float wave_size = 0.25;
uniform float face_distortion = 0.5;
uniform vec2 time_scale = vec2(0.3, 0.0);
uniform vec2 uv_offset_scale = vec2(-0.2, -0.1);

uniform sampler2D uv_offset_texture : hint_default_black; // This can be filled with Noise2DTexture created from the editor
uniform sampler2D albedo_texture : hint_default_white;
uniform sampler2D normal_texture : hint_normal;
uniform sampler2D roughness_texture : hint_roughness_r;


void vertex(){
	// Sample Noise
	vec2 base_uv_offset = UV * uv_offset_scale;
	base_uv_offset += TIME * time_scale * wind_speed;
	float noise = texture(uv_offset_texture, base_uv_offset).r;
	
	// Calculate offset
	float texture_based_offset = noise * 2.0 - 1.0; // Convert from 0.0  1.0 to -1.0  1.0
	texture_based_offset *= wave_size; // Apply amplitude
	
	texture_based_offset *= UV.y; // Apply dampening
	
	VERTEX.y += texture_based_offset * face_distortion; // Distort the face to give impression of conserving shape
	VERTEX.x += texture_based_offset * -face_distortion;
}


void fragment(){
	// Sample noise
	vec2 base_uv_offset = UV * uv_offset_scale;
	base_uv_offset += TIME * time_scale * wind_speed;
	float noise = texture(uv_offset_texture, base_uv_offset).r;
	vec4 albedo = texture(albedo_texture, UV);
	
	ALBEDO = albedo.rgb * clamp(noise, 0.5, 1.0) * 1.5;
	NORMAL_MAP = texture(normal_texture, UV * vec2(0.75, 3.0)).rgb;
	NORMAL_MAP_DEPTH = 0.2;
	ROUGHNESS = texture(roughness_texture, UV * vec2(0.75, 3.0)).r;
	EMISSION = ALBEDO * 0.1F;
}