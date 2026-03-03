shader_type canvas_item;

uniform vec4 rarity_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float border_width : hint_range(0.5, 3.0) = 1.0;
uniform float glow_intensity : hint_range(0.0, 2.0) = 0.5;
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.5;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float pulse = sin(TIME * pulse_speed) * 0.2 + 0.8;

	// Edge detection for border
	float alpha_sum = 0.0;
	vec2 pixel_size = TEXTURE_PIXEL_SIZE * border_width;
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			if (x == 0 && y == 0) continue;
			vec2 offset = vec2(float(x), float(y)) * pixel_size;
			alpha_sum += texture(TEXTURE, UV + offset).a;
		}
	}

	if (color.a < 0.1 && alpha_sum > 0.0) {
		// Border pixel
		COLOR = rarity_color * pulse * glow_intensity;
		COLOR.a = alpha_sum / 8.0;
	} else {
		COLOR = color;
	}
}
