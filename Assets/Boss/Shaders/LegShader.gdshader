shader_type canvas_item;

uniform float speed : hint_range(0.1, 10.0) = 2.0;
uniform float min_brightness : hint_range(0.0, 1.0) = 0.3;
uniform float max_rightness_modifier : hint_range(1.0, 5.0) = 5.0;
void fragment() {
    // Includes the Sprite2D texture and self_modulate
    vec4 sprite_color = COLOR;

    float adjust_sin = (sin(TIME * speed) + 1.0) * 0.5;
    float luminance = min_brightness +
        (max_rightness_modifier - min_brightness) * adjust_sin;

    COLOR = vec4(
        sprite_color.rgb * luminance,
        sprite_color.a
    );
}