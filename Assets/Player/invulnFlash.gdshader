shader_type canvas_item;

uniform float flashAmount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 modulate : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec3 flashed = mix(tex.rgb, vec3(1.0), flashAmount);
    COLOR = vec4(flashed, tex.a) * modulate;
}