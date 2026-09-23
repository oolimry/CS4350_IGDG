shader_type canvas_item;
render_mode blend_add;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float glow_width : hint_range(0.0, 20.0) = 5.0;
uniform float glow_intensity : hint_range(0.0, 5.0) = 1.5;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 original = texture(TEXTURE, UV);
    
    // Sample surrounding pixels to detect edges
    vec2 size = TEXTURE_PIXEL_SIZE * glow_width;
    float alpha = 0.0;
    
    // 8-directional sample
    alpha += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
    alpha += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
    alpha += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
    alpha += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
    
    alpha = clamp(alpha, 0.0, 1.0);
    
    // Only glow where original sprite is transparent
    float glow_alpha = alpha * (1.0 - original.a) * glow_intensity;
    vec4 glow = vec4(glow_color.rgb, glow_alpha);
    
    // Blend glow under original sprite
    COLOR = mix(glow, original, original.a);
	COLOR.a = min(1.0, COLOR.a) * opacity;
}