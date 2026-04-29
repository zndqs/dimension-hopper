shader_type canvas_item;

uniform float alignment_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float teleport_pulse : hint_range(0.0, 1.0) = 0.0;
uniform float fusion_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float shadow_alignment : hint_range(0.0, 1.0) = 0.0;
uniform float time_travel_blend : hint_range(0.0, 1.0) = 0.0;
uniform float time : hint_range(0.0, 100.0) = 0.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    // Vignette + center glow
    float vignette_radius = 0.8 - alignment_intensity * 0.3 - shadow_alignment * 0.2;
    float vignette_softness = 0.4 + alignment_intensity * 0.3 + shadow_alignment * 0.2;
    
    vec2 center_uv = UV - 0.5;
    float vignette = smoothstep(
        vignette_radius, 
        vignette_radius - vignette_softness, 
        length(center_uv)
    );
    
    float center_glow = 1.0 - length(center_uv) * 1.5;
    center_glow = max(0.0, center_glow) * (alignment_intensity * 0.5 + shadow_alignment * 0.3);
    
    // RGB chromatic aberration for teleport
    float chroma_amount = teleport_pulse * 0.03;
    float pulse_wave = sin(teleport_pulse * 3.14159 * 4.0);
    chroma_amount *= (1.0 - pulse_wave * 0.5);
    
    float r = texture(TEXTURE, UV + center_uv * chroma_amount).r;
    float g = color.g;
    float b = texture(TEXTURE, UV - center_uv * chroma_amount).b;
    
    color.rgb = vec3(r, g, b);
    
    // White flash on teleport
    float white_flash = pow(teleport_pulse, 2.0) * 0.6;
    color.rgb += white_flash * vec3(1.0, 0.98, 0.95);
    
    // Fusion blue tint + wave distortion
    if (fusion_intensity > 0.1) {
        float fusion_glow = fusion_intensity * 0.25;
        color.b += fusion_glow;
        color.g += fusion_glow * 0.3;
        
        float wave = sin(UV.x * 20.0 + time * 3.0) * fusion_intensity * 0.003;
        color = texture(TEXTURE, UV + vec2(wave));
    }
    
    // ==============================================
    //  SHADOW HISTORY EFFECTS
    // ==============================================
    
    // Shadow resonance: desaturated blue tint + subtle scanlines
    if (shadow_alignment > 0.05) {
        // Blue tint
        color.rgb = mix(color.rgb, color.rgb * vec3(0.8, 0.9, 1.2), shadow_alignment * 0.3);
        
        // CRT-style scanlines
        float scanline = sin(UV.y * 400.0 + time * 10.0) * 0.5 + 0.5;
        color.rgb *= 1.0 - scanline * shadow_alignment * 0.08;
        
        // Subtle desaturation
        float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));
        color.rgb = mix(color.rgb, vec3(luminance), shadow_alignment * 0.2);
    }
    
    // Time travel: heavy distortion + blue tunnel effect
    if (time_travel_blend > 0.001) {
        // Radial distortion (pull towards center)
        float dist = length(center_uv);
        float distortion = time_travel_blend * 0.4 * pow(1.0 - dist, 2.0);
        vec2 distorted_uv = UV - center_uv * distortion;
        color = texture(TEXTURE, distorted_uv);
        
        // Blue tunnel glow
        float tunnel_glow = pow(1.0 - dist * 1.5, 2.0) * time_travel_blend;
        color.rgb += tunnel_glow * vec3(0.2, 0.4, 1.0);
        
        // Heavy chromatic aberration during travel
        float travel_chroma = time_travel_blend * 0.08;
        float r_travel = texture(TEXTURE, distorted_uv + center_uv * travel_chroma).r;
        float b_travel = texture(TEXTURE, distorted_uv - center_uv * travel_chroma).b;
        color.r = mix(color.r, r_travel, time_travel_blend);
        color.b = mix(color.b, b_travel, time_travel_blend);
        
        // Whiteout at peak
        if (time_travel_blend > 0.7) {
            color.rgb += pow(time_travel_blend - 0.7, 2.0) * 2.0;
        }
    }
    
    // ==============================================
    //  FINAL COMPOSITING
    // ==============================================
    
    // Apply vignette
    color.rgb = mix(color.rgb, color.rgb * vignette, 0.4);
    color.rgb += center_glow * vec3(0.9, 0.95, 1.0);
    
    // Film grain
    float noise = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453);
    color.rgb += noise * (alignment_intensity + shadow_alignment * 0.5 + fusion_intensity) * 0.02;
    
    COLOR = color;
}
