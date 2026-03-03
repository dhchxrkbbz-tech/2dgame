shader_type canvas_item;

// Palette Swap Shader - Enemy variánsok vizuális megkülönböztetése
// Biome és al-típus alapján módosítja a színeket

uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.0;
uniform float brightness : hint_range(-1.0, 1.0) = 0.0;
uniform float saturation : hint_range(0.0, 2.0) = 1.0;

// Elite glow
uniform bool is_elite = false;
uniform vec4 elite_glow_color : source_color = vec4(1.0, 0.85, 0.0, 1.0);
uniform float elite_glow_strength : hint_range(0.0, 1.0) = 0.4;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	if (tex.a < 0.01) {
		discard;
	}
	
	// Saturation adjustment
	float gray = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	vec3 saturated = mix(vec3(gray), tex.rgb, saturation);
	
	// Brightness
	saturated += vec3(brightness);
	
	// Tint
	vec3 tinted = mix(saturated, tint_color.rgb, tint_strength);
	
	// Elite glow overlay
	if (is_elite) {
		// Edge glow: széleken erősebb
		float edge = 1.0 - smoothstep(0.0, 0.15, min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y)));
		tinted = mix(tinted, elite_glow_color.rgb, edge * elite_glow_strength);
		
		// Pulzáló fény
		float pulse = sin(TIME * 3.0) * 0.5 + 0.5;
		tinted += elite_glow_color.rgb * pulse * 0.1;
	}
	
	COLOR = vec4(tinted, tex.a);
}
