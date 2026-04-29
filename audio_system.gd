extends Node

@onready var audio_player: AudioStreamGeneratorPlayback

var carrier_freq_base = 110.0
var carrier_freq_target = 880.0
var carrier_phase = 0.0

var overtone_phase = 0.0
var overtone_mix = 0.0

var teleport_sweep = 0.0
var teleport_phase = 0.0

var fusion_chord_phase = 0.0
var fusion_chord_mix = 0.0

var shadow_resonance_phase = 0.0
var shadow_resonance_mix = 0.0
var shadow_sweep = 0.0

var alignment_intensity = 0.0
var fusion_intensity = 0.0
var shadow_alignment_intensity = 0.0

const PI = 3.1415926535

func _ready():
    var generator = AudioStreamGenerator.new()
    generator.mix_rate = 48000
    generator.buffer_length = 0.1
    
    var player_node = AudioStreamPlayer.new()
    player_node.stream = generator
    player_node.volume_db = -3.0
    add_child(player_node)
    player_node.play()
    
    audio_player = player_node.get_stream_playback()
    
    print("  [Audio] Pure synthesis system initialized - 48kHz stereo")

func update_sound(alignment_strength, fusion_strength, is_teleporting, delta):
    overtone_mix = lerp(overtone_mix, alignment_strength * 0.4, delta * 8.0)
    
    if is_teleporting and teleport_sweep < 1.0:
        teleport_sweep += delta * 4.0
    elif not is_teleporting and teleport_sweep > 0:
        teleport_sweep = max(0.0, teleport_sweep - delta * 2.0)
    
    fusion_chord_mix = lerp(fusion_chord_mix, fusion_strength, delta * 6.0)

func set_alignment_intensity(value):
    alignment_intensity = clamp(value, 0.0, 1.0)

func set_fusion_intensity(value):
    fusion_intensity = clamp(value, 0.0, 1.0)

func set_shadow_alignment_intensity(value):
    shadow_alignment_intensity = clamp(value, 0.0, 1.0)
    shadow_resonance_mix = lerp(shadow_resonance_mix, value, 0.1)

func trigger_shadow_resonance():
    shadow_sweep = 0.001

func trigger_teleport():
    teleport_sweep = 0.001

func trigger_fusion():
    fusion_chord_phase = 0.0

func lerp(a, b, t):
    return a + (b - a) * t

func _process(delta):
    if not audio_player:
        return
    
    var mix_rate = 48000.0
    var frames_needed = audio_player.get_frames_available()
    
    var freq = lerp(carrier_freq_base, carrier_freq_target, 
                   pow(max(alignment_intensity, fusion_intensity), 1.5))
    
    for i in range(frames_needed):
        # ==============================================
        #  OSCILLATOR 1: Alignment Carrier Sine Wave
        # ==============================================
        carrier_phase += freq * 2.0 * PI / mix_rate
        if carrier_phase > 2.0 * PI:
            carrier_phase -= 2.0 * PI
        
        var carrier = sin(carrier_phase) * 0.3
        
        # ==============================================
        #  OSCILLATOR 2: Alignment Overtone (3rd harmonic)
        # ==============================================
        overtone_phase += freq * 3.0 * 2.0 * PI / mix_rate
        if overtone_phase > 2.0 * PI:
            overtone_phase -= 2.0 * PI
        
        var overtone = sin(overtone_phase) * overtone_mix * 0.15
        
        # ==============================================
        #  OSCILLATOR 3: Teleport Sweep (exponential rise)
        # ==============================================
        var teleport_sound = 0.0
        if teleport_sweep > 0.001:
            var sweep_freq = 100.0 + pow(teleport_sweep, 3.0) * 8000.0
            teleport_phase += sweep_freq * 2.0 * PI / mix_rate
            if teleport_phase > 2.0 * PI:
                teleport_phase -= 2.0 * PI
            
            teleport_sound = sin(teleport_phase) * (1.0 - teleport_sweep) * 0.4
            
            if teleport_sweep > 0.4 and teleport_sweep < 0.45:
                teleport_sound += 0.3
        
        # ==============================================
        #  OSCILLATOR 4: Fusion Chord (Major triad arpeggio)
        # ==============================================
        var chord = 0.0
        if fusion_chord_mix > 0.01:
            var chord_root = 440.0
            var chord_3rd = 554.37
            var chord_5th = 659.25
            
            var arp_speed = 8.0
            var arp_phase = fmod(fusion_chord_phase * arp_speed, 3.0)
            
            fusion_chord_phase += 1.0 / mix_rate
            
            if arp_phase < 1.0:
                chord = sin(fusion_chord_phase * chord_root * 2.0 * PI) * 0.2
            elif arp_phase < 2.0:
                chord = sin(fusion_chord_phase * chord_3rd * 2.0 * PI) * 0.15
            else:
                chord = sin(fusion_chord_phase * chord_5th * 2.0 * PI) * 0.12
            
            chord *= fusion_chord_mix
        
        # ==============================================
        #  OSCILLATOR 6: Shadow Resonance (Subsonic + Whistling)
        # ==============================================
        var shadow_sound = 0.0
        if shadow_resonance_mix > 0.01:
            # Deep subsonic hum (E1 - 41.2Hz) + high ethereal overtone
            var shadow_root = 41.2
            var shadow_overtone = 2469.4  # D7
            
            shadow_resonance_phase += 1.0 / mix_rate
            
            var hum = sin(shadow_resonance_phase * shadow_root * 2.0 * PI) * 0.25
            var whisper = sin(shadow_resonance_phase * shadow_overtone * 2.0 * PI) * 0.05
            shadow_sound = (hum + whisper) * shadow_resonance_mix
        
        # ==============================================
        #  OSCILLATOR 7: Shadow Time Travel Sweep
        # ==============================================
        if shadow_sweep > 0.001:
            shadow_sweep += 1.0 / mix_rate * 2.0
            if shadow_sweep < 1.0:
                var sweep_freq = 30.0 + pow(shadow_sweep, 2.0) * 4000.0
                var sweep_phase = shadow_sweep * 100.0
                shadow_sound += sin(sweep_phase * sweep_freq * 2.0 * PI) * (1.0 - shadow_sweep) * 0.3
            else:
                shadow_sweep = 0.0
        
        # ==============================================
        #  OSCILLATOR 5: Subtle Noise Grain
        # ==============================================
        var grain = randf() * 2.0 - 1.0
        grain *= max(alignment_intensity, fusion_intensity) * 0.02
        
        # ==============================================
        #  FINAL MIX
        # ==============================================
        var sample = carrier + overtone + teleport_sound + chord + shadow_sound + grain
        
        var left = sample * 0.8
        var right = sample * 0.8 + overtone * 0.3
        
        audio_player.push_frame(Vector2(left, right))
