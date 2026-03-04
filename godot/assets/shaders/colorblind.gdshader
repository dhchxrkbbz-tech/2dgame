shader_type canvas_item;

// Colorblind Accessibility Shader
// Módok: 0=Off, 1=Protanopia, 2=Deuteranopia, 3=Tritanopia
// Ez a shader a teljes viewport-ra alkalmazva színkorrekciót végez

uniform int mode : hint_range(0, 3) = 0;
uniform float strength : hint_range(0.0, 1.0) = 1.0;

// Színtévesztő szimulációs mátrixok (Machado et al. 2009 alapján)
// Ezek a mátrixok a daltonizáció korrekcióját végzik

vec3 apply_protanopia(vec3 color) {
	// Protanopia: vörös csapok hiánya
	// Korrekciós mátrix: vörös → narancssárga/sárga tónusok
	mat3 correction = mat3(
		vec3(0.567, 0.433, 0.0),
		vec3(0.558, 0.442, 0.0),
		vec3(0.0, 0.242, 0.758)
	);
	vec3 corrected = correction * color;
	
	// HP bar / damage jelzés: vörös → fehéres narancs
	// Méreg jelzés: zöld → lila
	float red_amount = max(color.r - color.g - color.b, 0.0);
	float green_amount = max(color.g - color.r * 0.5 - color.b * 0.5, 0.0);
	
	// Vörös tónusok → narancs felé tolás
	corrected.r += red_amount * 0.3;
	corrected.g += red_amount * 0.15;
	
	// Zöld tónusok → kékes lila felé tolás
	corrected.b += green_amount * 0.4;
	corrected.r += green_amount * 0.2;
	corrected.g -= green_amount * 0.3;
	
	return clamp(corrected, 0.0, 1.0);
}

vec3 apply_deuteranopia(vec3 color) {
	// Deuteranopia: zöld csapok hiánya
	mat3 correction = mat3(
		vec3(0.625, 0.375, 0.0),
		vec3(0.7, 0.3, 0.0),
		vec3(0.0, 0.3, 0.7)
	);
	vec3 corrected = correction * color;
	
	float green_amount = max(color.g - color.r * 0.5 - color.b * 0.5, 0.0);
	
	// Zöld tónusok → kék felé tolás
	corrected.b += green_amount * 0.5;
	corrected.g -= green_amount * 0.2;
	
	return clamp(corrected, 0.0, 1.0);
}

vec3 apply_tritanopia(vec3 color) {
	// Tritanopia: kék csapok hiánya
	mat3 correction = mat3(
		vec3(0.95, 0.05, 0.0),
		vec3(0.0, 0.433, 0.567),
		vec3(0.0, 0.475, 0.525)
	);
	vec3 corrected = correction * color;
	
	float blue_amount = max(color.b - color.r * 0.5 - color.g * 0.5, 0.0);
	float yellow_amount = max(min(color.r, color.g) - color.b * 0.5, 0.0);
	
	// Kék → cián felé
	corrected.g += blue_amount * 0.3;
	
	// Sárga → fehéres arany
	corrected.b += yellow_amount * 0.2;
	
	return clamp(corrected, 0.0, 1.0);
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	if (mode == 0 || strength < 0.01) {
		COLOR = tex;
		return;
	}
	
	vec3 corrected;
	
	if (mode == 1) {
		corrected = apply_protanopia(tex.rgb);
	} else if (mode == 2) {
		corrected = apply_deuteranopia(tex.rgb);
	} else if (mode == 3) {
		corrected = apply_tritanopia(tex.rgb);
	} else {
		corrected = tex.rgb;
	}
	
	// Strength blending
	vec3 final_color = mix(tex.rgb, corrected, strength);
	
	COLOR = vec4(final_color, tex.a);
}
