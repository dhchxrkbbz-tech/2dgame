shader_type canvas_item;

// Elite Aura Shader - Pulzáló aura effect elite enemy-k körül
// Affix típus alapján változó szín

uniform vec4 aura_color_1 : source_color = vec4(1.0, 0.85, 0.0, 0.6);
uniform vec4 aura_color_2 : source_color = vec4(1.0, 0.5, 0.0, 0.3);
uniform float aura_radius : hint_range(0.0, 0.5) = 0.15;
uniform float pulse_speed : hint_range(0.5, 5.0) = 2.0;
uniform float distortion : hint_range(0.0, 0.1) = 0.02;
uniform int affix_count : hint_range(1, 3) = 1;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	if (tex.a < 0.01) {
		discard;
	}
	
	// Pulzáló aura határ
	float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
	float current_radius = aura_radius * (0.8 + pulse * 0.4);
	
	// Távolság a szélektől
	float dist_x = min(UV.x, 1.0 - UV.x);
	float dist_y = min(UV.y, 1.0 - UV.y);
	float edge_dist = min(dist_x, dist_y);
	
	// Aura intensity
	float aura = smoothstep(current_radius, 0.0, edge_dist);
	
	// Torzítás a széleken
	vec2 dist_uv = UV;
	if (edge_dist < current_radius) {
		float angle = TIME * 1.5;
		dist_uv += vec2(sin(angle + UV.y * 10.0), cos(angle + UV.x * 10.0)) * distortion * aura;
	}
	
	// Szín keverés affix szám alapján
	vec4 final_aura;
	if (affix_count >= 2) {
		// Több affix: szín váltakozás
		float color_mix = sin(TIME * 1.5 + UV.x * 5.0) * 0.5 + 0.5;
		final_aura = mix(aura_color_1, aura_color_2, color_mix);
	} else {
		final_aura = aura_color_1;
	}
	
	// 3 affix: erősebb, gyorsabb pulzálás
	float intensity = 1.0;
	if (affix_count >= 3) {
		intensity = 1.3;
		float fast_pulse = sin(TIME * 4.0) * 0.3 + 0.7;
		aura *= fast_pulse;
	}
	
	// Végső összekeverés
	vec3 result = mix(tex.rgb, final_aura.rgb, aura * final_aura.a * intensity);
	
	COLOR = vec4(result, tex.a);
}
