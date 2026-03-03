// Corruption shader - Sötét rombolás/fertőzés vizuális effekt
// Plague Lands, boss arénák, cursed területek
shader_type canvas_item;

uniform vec4 corruption_color : source_color = vec4(0.3, 0.05, 0.4, 1.0);
uniform vec4 corruption_highlight : source_color = vec4(0.6, 0.1, 0.8, 1.0);
uniform vec4 corruption_dark : source_color = vec4(0.1, 0.0, 0.15, 1.0);
uniform float corruption_amount : hint_range(0.0, 1.0) = 0.5;
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.0;
uniform float noise_scale : hint_range(1.0, 20.0) = 8.0;
uniform float spread_speed : hint_range(0.0, 2.0) = 0.3;
uniform float vein_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float desaturation : hint_range(0.0, 1.0) = 0.7;
uniform vec2 corruption_origin = vec2(0.5, 0.5);

// Egyszerű hash-alapú pseudo-random (noise texture nélkül)
float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// Értéknoise
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// FBM (Fractal Brownian Motion)
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    // Corruption noise
    float corruption_noise = fbm(UV * noise_scale + TIME * spread_speed * 0.1);
    
    // Távolság a corruption origintól
    float dist = distance(UV, corruption_origin);
    float spread = 1.0 - smoothstep(0.0, 0.5 / corruption_amount, dist);
    
    // Corruption maszk
    float corruption_mask = corruption_noise * spread * corruption_amount;
    corruption_mask = smoothstep(0.3, 0.7, corruption_mask);
    
    // Pulzálás
    float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
    corruption_mask *= 0.8 + pulse * 0.2;
    
    // Erek (veins)
    float veins = fbm(UV * noise_scale * 2.0 + TIME * 0.2);
    veins = smoothstep(0.4, 0.6, veins) * vein_intensity;
    float vein_mask = veins * corruption_mask;
    
    // Desaturáció
    float gray = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    vec3 desaturated = mix(tex.rgb, vec3(gray), desaturation * corruption_mask);
    
    // Corruption szín keverés
    vec3 corrupt_color = mix(corruption_color.rgb, corruption_highlight.rgb, pulse * 0.3);
    corrupt_color = mix(corrupt_color, corruption_dark.rgb, corruption_noise * 0.5);
    
    // Végső szín
    vec3 final_color = mix(desaturated, corrupt_color, corruption_mask * 0.6);
    
    // Vein highlight
    final_color += corruption_highlight.rgb * vein_mask * 0.5;
    
    // Széleken enyhe glow
    float edge_glow = smoothstep(0.5, 0.3, abs(corruption_mask - 0.5));
    final_color += corruption_highlight.rgb * edge_glow * 0.2;
    
    COLOR = vec4(final_color, tex.a);
}
