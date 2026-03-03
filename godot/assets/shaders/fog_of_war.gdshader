shader_type canvas_item;

// Fog of War shader - Dungeon rendszer
// Dinamikusan frissített fog_texture alapján kezeli a láthatóságot
// fog_texture.r értékek: 0.0 = hidden, 0.5 = explored, 1.0 = visible

uniform sampler2D fog_texture : filter_nearest;
uniform float explored_alpha : hint_range(0.0, 1.0) = 0.4;
uniform float visible_alpha : hint_range(0.0, 1.0) = 0.0;
uniform float hidden_alpha : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	float fog_value = texture(fog_texture, UV).r;
	float alpha;
	if (fog_value > 0.9) {
		alpha = visible_alpha;     // Most látja a player
	} else if (fog_value > 0.1) {
		alpha = explored_alpha;    // Korábban látta (sötétebb)
	} else {
		alpha = hidden_alpha;      // Soha nem látta (fekete)
	}
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
