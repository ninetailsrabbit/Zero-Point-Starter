shader_type canvas_item;
void fragment() {
    // Get the texture size
    vec2 texture_size = vec2(textureSize(TEXTURE, 0));   
    // Calculate the box filter size in texel units
    vec2 box_size = clamp(fwidth(UV) * texture_size, vec2(1e-5), vec2(1.0));
    // Scale UV by texture size to get texel coordinate
    vec2 tx = UV * texture_size - 0.5 * box_size;
    // Compute offset for pixel-sized box filter
    vec2 tx_offset = clamp((fract(tx) - (vec2(1.0) - box_size)) / box_size, vec2(0.0), vec2(1.0));
    // Compute bilinear sample UV coordinates
    vec2 uv = (floor(tx) + vec2(0.5) + tx_offset) / texture_size;
    // Sample the texture using the original UV coordinates
    vec4 color = texture(TEXTURE, uv);
    // Set the output color
    COLOR = color;
}