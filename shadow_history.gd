extends Node

# ==============================================
#  DIMENSION HOPPER - Shadow History Mechanism
#  
#  "You yourself are the key."
#  
#  Records player movement, plays it back as semi-transparent shadows.
#  When player aligns with their past self, they can time travel.
# ==============================================

class_name ShadowHistory

@onready var player: CharacterBody3D = $"/root/GameRoot/Player"
@onready var player_mesh: MeshInstance3D = $ShadowMesh
@onready var audio_system: Node = $"/root/GameRoot/AudioSystem"

# Recording settings
const RECORD_INTERVAL = 0.05  # Record every 50ms
const MAX_RECORD_SECONDS = 30.0
const RECORDED_FRAMES = int(MAX_RECORD_SECONDS / RECORD_INTERVAL)

var record_buffer: Array = []
var record_timer = 0.0
var is_recording = true

# Playback settings
var playback_position = 0.0
var is_playing_back = false
var playback_speed = 1.0

# Alignment detection
var alignment_threshold = 0.5  # meters
var rotation_threshold = 0.3  # radians (~17 degrees)
var is_aligned_with_shadow = false
var alignment_intensity = 0.0

# Shadow visual state
var shadow_opacity = 0.3
var shadow_glow = 0.0

# Time travel state
var is_time_traveling = false
var time_travel_blend = 0.0

func _ready():
    # Initialize shadow mesh (semi-transparent capsule)
    var capsule_mesh = CapsuleMesh.new()
    capsule_mesh.radius = 0.5
    capsule_mesh.height = 1.8
    
    var shadow_material = StandardMaterial3D.new()
    shadow_material.albedo_color = Color(0.2, 0.4, 0.8, 0.3)
    shadow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    shadow_material.emission = Color(0.3, 0.5, 1.0)
    shadow_material.emission_enabled = true
    
    player_mesh.mesh = capsule_mesh
    player_mesh.material_override = shadow_material
    
    # Pre-allocate buffer
    record_buffer.resize(RECORDED_FRAMES)
    
    print("  [Shadow] History recorder initialized - buffer size: ", RECORDED_FRAMES, " frames")

func start_recording():
    is_recording = true
    record_buffer.clear()

func stop_recording():
    is_recording = false

func _process(delta):
    if is_recording and not is_time_traveling:
        record_timer += delta
        if record_timer >= RECORD_INTERVAL:
            record_frame()
            record_timer = 0.0
    
    # Always play back the shadow (looped)
    if record_buffer.size() > 10:
        playback_position += delta * playback_speed
        if playback_position >= record_buffer.size() * RECORD_INTERVAL:
            playback_position = 0.0
        
        update_shadow_visuals()
        check_shadow_alignment()
    
    # Time travel blend effect
    if is_time_traveling:
        time_travel_blend += delta * 2.0
        if time_travel_blend >= 1.0:
            complete_time_travel()

func record_frame():
    var frame = {
        "position": player.global_position,
        "rotation": player.global_rotation,
        "timestamp": Time.get_ticks_msec()
    }
    
    record_buffer.push_back(frame)
    
    # Keep buffer at max size
    if record_buffer.size() > RECORDED_FRAMES:
        record_buffer.pop_front()

func get_frame_at_time(time_seconds):
    var frame_index = int(time_seconds / RECORD_INTERVAL)
    frame_index = clamp(frame_index, 0, record_buffer.size() - 1)
    
    if frame_index >= 0 and frame_index < record_buffer.size():
        return record_buffer[frame_index]
    return null

func update_shadow_visuals():
    var frame = get_frame_at_time(playback_position)
    if not frame:
        return
    
    # Move shadow to recorded position
    player_mesh.global_position = frame.position
    player_mesh.global_rotation = frame.rotation
    
    # Visual effect: shadow gets brighter when close to alignment
    var mat = player_mesh.material_override as StandardMaterial3D
    var target_emission = 0.3 + alignment_intensity * 1.5
    mat.emission = Color(0.3, 0.5, 1.0) * target_emission
    mat.albedo_color.a = 0.3 + alignment_intensity * 0.4

func check_shadow_alignment():
    var frame = get_frame_at_time(playback_position)
    if not frame or is_time_traveling:
        is_aligned_with_shadow = false
        alignment_intensity = 0.0
        return
    
    # Calculate position difference
    var pos_diff = player.global_position.distance_to(frame.position)
    
    # Calculate rotation difference (Y axis only - horizontal facing)
    var rot_diff = abs(player.global_rotation.y - frame.rotation.y)
    rot_diff = min(rot_diff, 2.0 * 3.14159 - rot_diff)
    
    # Combined alignment score (position + facing)
    var pos_score = 1.0 - smoothstep(0.0, alignment_threshold * 2.0, pos_diff)
    var rot_score = 1.0 - smoothstep(0.0, rotation_threshold * 2.0, rot_diff)
    
    alignment_intensity = pos_score * rot_score
    is_aligned_with_shadow = alignment_intensity > 0.85

func trigger_time_travel():
    if not is_aligned_with_shadow or is_time_traveling:
        return false
    
    is_time_traveling = true
    time_travel_blend = 0.0
    
    print("")
    print("  ==================================================")
    print("  *   SHADOW ALIGNMENT - TIME TRAVEL ACTIVATED!   *")
    print("  ==================================================")
    print("")
    
    return true

func complete_time_travel():
    var frame = get_frame_at_time(playback_position)
    if not frame:
        reset_travel_state()
        return
    
    # Jump player to shadow position
    player.global_position = frame.position
    player.global_rotation = frame.rotation
    
    # Clear future (we've changed the past)
    var frame_index = int(playback_position / RECORD_INTERVAL)
    record_buffer = record_buffer.slice(0, frame_index)
    
    reset_travel_state()
    
    print("  >>> You have merged with your past self <<<")

func reset_travel_state():
    is_time_traveling = false
    time_travel_blend = 0.0
    is_aligned_with_shadow = false
    alignment_intensity = 0.0

func smoothstep(edge0, edge1, x):
    var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)

# Getters for game integration
func get_alignment_intensity():
    return alignment_intensity

func is_aligned():
    return is_aligned_with_shadow

func get_time_travel_blend():
    return time_travel_blend

# Audio trigger hook (called from game.gd)
func on_aligned():
    if audio_system and audio_system.has_method("trigger_shadow_resonance"):
        audio_system.trigger_shadow_resonance()
