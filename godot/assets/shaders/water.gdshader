// Water shader - 2D pixel art víz effekt
// Hullámzás, tükröződés, átlátszóság
shader_type canvas_item;

uniform vec4 water_color : source_color = vec4(0.1, 0.3, 0.6, 0.7);
uniform vec4 foam_color : source_color = vec4(0.6, 0.8, 0.9, 0.8);
uniform float wave_speed : hint_range(0.0, 5.0) = 1.0;
uniform float wave_amplitude : hint_range(0.0, 0.1) = 0.02;
uniform float wave_frequency : hint_range(0.0, 20.0) = 8.0;
uniform float foam_threshold : hint_range(0.0, 1.0) = 0.7;
uniform float reflection_strength : hint_range(0.0, 1.0) = 0.3;
uniform float shimmer_speed : hint_range(0.0, 3.0) = 0.5;
uniform float shimmer_intensity : hint_range(0.0, 1.0) = 0.15;
uniform float pixel_size : hint_range(1.0, 8.0) = 2.0;
uniform float distortion : hint_range(0.0, 0.05) = 0.01;

void fragment() {
    // Pixelizált UV a pixel art stílushoz
    vec2 pixel_uv = floor(UV * (1.0 / pixel_size) * 256.0) / 256.0 * pixel_size;
    
    // Hullám offset
    float wave_offset = sin(pixel_uv.x * wave_frequency + TIME * wave_speed) * wave_amplitude;
    float wave_offset2 = cos(pixel_uv.y * wave_frequency * 0.7 + TIME * wave_speed * 0.8) * wave_amplitude * 0.5;
    
    vec2 distorted_uv = UV;
    distorted_uv.y += wave_offset;
    distorted_uv.x += wave_offset2;
    
    // Base texture
    vec4 tex = texture(TEXTURE, distorted_uv);
    
    // Víz szín keverés
    vec4 result = mix(tex, water_color, water_color.a);
    
    // Shimmer (csillanás)
    float shimmer = sin(pixel_uv.x * 30.0 + TIME * shimmer_speed) *
                    cos(pixel_uv.y * 25.0 + TIME * shimmer_speed * 1.3);
    shimmer = smoothstep(0.5, 1.0, shimmer) * shimmer_intensity;
    result.rgb += vec3(shimmer);
    
    // Hab (szélek közelében)
    float foam_noise = sin(pixel_uv.x * 15.0 + TIME * 0.5) *
                       cos(pixel_uv.y * 12.0 - TIME * 0.3);
    foam_noise = foam_noise * 0.5 + 0.5;
    
    // Hab a széleken (UV.y == 0 vagy 1 közelében)
    float edge_factor = 1.0 - abs(UV.y - 0.5) * 2.0;
    float foam = step(foam_threshold, foam_noise * (1.0 - edge_factor));
    result = mix(result, foam_color, foam * 0.5);
    
    // Tükröződés (felső rész tükrözése)
    if (reflection_strength > 0.0) {
        vec2 reflect_uv = vec2(UV.x + distortion * sin(TIME), 1.0 - UV.y);
        vec4 reflected = texture(TEXTURE, reflect_uv);
        result = mix(result, reflected, reflection_strength * 0.3);
    }
    
    // Átlátszóság
    result.a = water_color.a;
    
    COLOR = result;
}
