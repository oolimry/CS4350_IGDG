shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform vec4 recolor : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float hdrBrightness : hint_range(1.0, 10.0) = 3.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float whiteness = min(tex.r, min(tex.g, tex.b)) * tex.a;

    COLOR = vec4(recolor.rgb * whiteness * hdrBrightness, whiteness * recolor.a);
}