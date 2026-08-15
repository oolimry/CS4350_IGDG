shader_type canvas_item;

uniform float flashAmount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    vec3 color = mix(tex.rgb, vec3(1.0), flashAmount);

    COLOR = vec4(color, tex.a);
}