// Day/Night cycle shader - CanvasItem
// Biome-specifikus tint + nap/éjszaka szín módosítás
shader_type canvas_item;

uniform vec4 day_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 night_color : source_color = vec4(0.2, 0.2, 0.4, 1.0);
uniform vec4 dawn_color : source_color = vec4(0.8, 0.7, 0.5, 1.0);
uniform vec4 dusk_color : source_color = vec4(0.9, 0.6, 0.4, 1.0);
uniform vec4 biome_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float time_of_day : hint_range(0.0, 24.0) = 12.0;
uniform float intensity : hint_range(0.0, 1.0) = 1.0;

// Fényforrás hatás
uniform vec2 torch_position = vec2(0.5, 0.5);
uniform float torch_radius : hint_range(0.0, 1.0) = 0.2;
uniform float torch_intensity : hint_range(0.0, 2.0) = 1.0;
uniform vec4 torch_color : source_color = vec4(1.0, 0.8, 0.5, 1.0);

vec4 get_time_color(float t) {
    // t: 0-24 óra
    if (t < 5.0) {
        // Éjszaka
        return night_color;
    } else if (t < 7.0) {
        // Hajnal
        float f = (t - 5.0) / 2.0;
        return mix(night_color, dawn_color, f);
    } else if (t < 9.0) {
        // Hajnal → nappal
        float f = (t - 7.0) / 2.0;
        return mix(dawn_color, day_color, f);
    } else if (t < 17.0) {
        // Nappal
        return day_color;
    } else if (t < 19.0) {
        // Nappal → alkony
        float f = (t - 17.0) / 2.0;
        return mix(day_color, dusk_color, f);
    } else if (t < 21.0) {
        // Alkony → éjszaka
        float f = (t - 19.0) / 2.0;
        return mix(dusk_color, night_color, f);
    } else {
        // Éjszaka
        return night_color;
    }
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    // Nap/éjszaka szín
    vec4 time_color = get_time_color(time_of_day);
    
    // Biome tint alkalmazása
    vec4 tinted = tex * time_color * biome_tint;
    
    // Fáklya fény (pont fényforrás)
    float dist = distance(UV, torch_position);
    float torch_factor = 1.0 - smoothstep(0.0, torch_radius, dist);
    torch_factor *= torch_intensity;
    
    // Fény hozzáadása
    vec4 lit = mix(tinted, tex * torch_color, torch_factor);
    
    // Intensity
    COLOR = mix(tex, lit, intensity);
    COLOR.a = tex.a;
}
