shader_type canvas_item;
render_mode unshaded;

uniform vec4 base_color : source_color = vec4(0.1, 0.4, 0.9, 0.45);
uniform vec4 highlight_color : source_color = vec4(0.7, 0.95, 1.0, 0.85);
uniform float speed = 0.25;
uniform float noise_scale = 3.0;
uniform float turbulence = 1.5;       // how strongly the noise warps itself
uniform float edge_softness = 0.1;    // 0 = hard edges
uniform vec2 aspect = vec2(1.0, 1.0); // set to rect size / min(size) to avoid stretching

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash(i), hash(i + vec2(1, 0)), f.x),
		mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x),
		f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * noise(p);
		p *= 2.0;
		a *= 0.5;
	}
	return v;
}

void fragment() {
	float t = TIME * speed;
	vec2 p = UV * aspect * noise_scale;

	// Domain warp: noise that distorts the lookup of more noise
	vec2 q = vec2(fbm(p + vec2(0.0, t)), fbm(p + vec2(5.2, 1.3) - t));
	float n = fbm(p + turbulence * q + t * 0.5);

	vec4 col = mix(base_color, highlight_color, smoothstep(0.25, 0.75, n));

	// Fade out near the rectangle's edges
	vec2 d = min(UV, 1.0 - UV);
	float edge = smoothstep(0.0, max(edge_softness, 0.0001), min(d.x, d.y));

	COLOR = vec4(col.rgb, col.a * edge);
}