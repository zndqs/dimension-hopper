extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var camera: Camera3D = $Player/Camera3D
@onready var alignment_light: OmniLight3D = $Player/AlignmentLight
@onready var post_process: ColorRect = $CanvasLayer/PostProcess
@onready var shader_material: ShaderMaterial = post_process.material
@onready var audio_system: Node = $AudioSystem
@onready var shadow_system: Node = $ShadowSystem

@onready var wall_near: MeshInstance3D = $Wall_Near
@onready var wall_far: MeshInstance3D = $Wall_Far
@onready var teleport_target: Node3D = $TeleportTarget

@onready var key_object: MeshInstance3D = $FusionKey
@onready var lock_object: MeshInstance3D = $FusionLock
@onready var fusion_door: StaticBody3D = $FusionDoor
@onready var door_collision: CollisionShape3D = $FusionDoor/CollisionShape3D

var alignment_threshold = 0.015
var is_aligned = false
var alignment_intensity = 0.0

var fusion_threshold = 0.03
var is_fused = false
var fusion_intensity = 0.0
var door_opened = false

var shadow_aligned = false
var shadow_alignment_intensity = 0.0
var time_traveling = false

var move_speed = 6.0
var mouse_sensitivity = 0.0025
var camera_rotation = Vector2.ZERO

var has_teleported = false
var has_time_traveled = false
var teleport_cooldown = 0.0
var teleport_pulse = 0.0
var fusion_cooldown = 0.0

var game_time = 0.0

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    print("")
    print("=============================================================")
    print("  DIMENSION HOPPER - PROTOTYPE v0.5")
    print("=============================================================")
    print("")
    print("  NEW: Shadow History Mechanism!")
    print("    * Your past movements recorded and played back")
    print("    * Semi-transparent shadow repeats your actions")
    print("    * Align with your shadow to time travel")
    print("    * Subsonic resonance + time tunnel visual effects")
    print("")
    print("  CONTROLS: WASD Move, Mouse Look, SPACE Activate")
    print("")
    print("=============================================================")
    print("")

func _input(event):
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        camera_rotation.x -= event.relative.x * mouse_sensitivity
        camera_rotation.y -= event.relative.y * mouse_sensitivity
        camera_rotation.y = clamp(camera_rotation.y, -PI/2 + 0.1, PI/2 - 0.1)
        
        player.transform.basis = Basis.IDENTITY
        player.rotate_y(camera_rotation.x)
        camera.rotation.x = camera_rotation.y

func _process(delta):
    game_time += delta
    
    # Get shadow state
    shadow_alignment_intensity = shadow_system.get_alignment_intensity()
    shadow_aligned = shadow_system.is_aligned()
    time_traveling = shadow_system.get_time_travel_blend() > 0.001
    
    # Update all shader parameters
    shader_material.set_shader_parameter("alignment_intensity", alignment_intensity)
    shader_material.set_shader_parameter("fusion_intensity", fusion_intensity)
    shader_material.set_shader_parameter("shadow_alignment", shadow_alignment_intensity)
    shader_material.set_shader_parameter("time_travel_blend", shadow_system.get_time_travel_blend())
    shader_material.set_shader_parameter("time", game_time)
    
    # Update audio system
    audio_system.set_alignment_intensity(max(alignment_intensity, fusion_intensity))
    audio_system.set_fusion_intensity(fusion_intensity)
    audio_system.set_shadow_alignment_intensity(shadow_alignment_intensity)
    audio_system.update_sound(max(alignment_intensity, fusion_intensity), fusion_intensity, teleport_pulse > 0.1, delta)
    
    # Teleport pulse animation
    if teleport_pulse > 0:
        teleport_pulse -= delta * 1.5
        teleport_pulse = max(0.0, teleport_pulse)
        shader_material.set_shader_parameter("teleport_pulse", teleport_pulse)

func _physics_process(delta):
    handle_movement(delta)
    check_edge_alignment()
    check_perspective_fusion()
    update_visual_feedback(delta)
    
    if teleport_cooldown > 0:
        teleport_cooldown -= delta
    if fusion_cooldown > 0:
        fusion_cooldown -= delta
    
    # Wall teleport
    if is_aligned and Input.is_action_just_pressed("ui_accept") and teleport_cooldown <= 0:
        perform_teleport()
    
    # Key-lock fusion
    if is_fused and Input.is_action_just_pressed("ui_accept") and fusion_cooldown <= 0:
        perform_fusion()
    
    # Shadow time travel
    if shadow_aligned and Input.is_action_just_pressed("ui_accept") and teleport_cooldown <= 0:
        if shadow_system.trigger_time_travel():
            audio_system.trigger_shadow_resonance()
            teleport_cooldown = 2.0

func handle_movement(delta):
    var input_dir = Input.get_vector("left", "right", "forward", "backward")
    var direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    player.velocity.x = direction.x * move_speed
    player.velocity.z = direction.z * move_speed
    player.move_and_slide()

func check_edge_alignment():
    is_aligned = false
    alignment_intensity = 0.0
    
    var screen_near = camera.unproject_position(wall_near.global_position)
    var screen_far = camera.unproject_position(wall_far.global_position)
    
    var screen_distance = screen_near.distance_to(screen_far)
    var intensity = 1.0 - smoothstep(0.0, 150.0, screen_distance)
    
    alignment_intensity = intensity
    is_aligned = intensity > 0.85

func check_perspective_fusion():
    is_fused = false
    fusion_intensity = 0.0
    
    if door_opened:
        return
    
    var screen_key = camera.unproject_position(key_object.global_position)
    var screen_lock = camera.unproject_position(lock_object.global_position)
    var screen_distance = screen_key.distance_to(screen_lock)
    
    var intensity = 1.0 - smoothstep(0.0, 40.0, screen_distance)
    fusion_intensity = intensity
    is_fused = intensity > 0.9

func perform_teleport():
    print("")
    print("  ==================================================")
    print("  *   DIMENSION HOP - TELEPORT SUCCESSFUL!        *")
    print("  ==================================================")
    print("")
    
    teleport_pulse = 1.0
    audio_system.trigger_teleport()
    
    player.global_position = teleport_target.global_position
    teleport_cooldown = 1.5
    camera.reset_smoothing()

func perform_fusion():
    print("")
    print("  ==================================================")
    print("  *   PERSPECTIVE FUSION - DOOR UNLOCKED!         *")
    print("  ==================================================")
    print("")
    
    door_opened = true
    door_collision.disabled = true
    audio_system.trigger_fusion()
    
    var tween = create_tween()
    tween.tween_property(fusion_door, "position:y", fusion_door.position.y + 4.0, 1.5)
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_ELASTIC)
    
    fusion_cooldown = 1.0

func update_visual_feedback(delta):
    var target_energy = 0.5 + alignment_intensity * 8.0 + fusion_intensity * 6.0 + shadow_alignment_intensity * 4.0
    alignment_light.light_energy = lerp(alignment_light.light_energy, target_energy, delta * 10.0)
    alignment_light.light_color = Color(0.8 + shadow_alignment_intensity * 0.2, 0.9, 1.0)
    
    if alignment_intensity > 0.3 or fusion_intensity > 0.3 or shadow_alignment_intensity > 0.3:
        var shake_x = randf_range(-1, 1) * max(alignment_intensity, fusion_intensity, shadow_alignment_intensity) * 2.5
        var shake_y = randf_range(-1, 1) * max(alignment_intensity, fusion_intensity, shadow_alignment_intensity) * 2.5
        camera.position = Vector3(shake_x * 0.006, shake_y * 0.006, 0)
    else:
        camera.position = Vector3.ZERO
    
    if is_aligned and not has_teleported:
        print("  >>> WALLS ALIGNED! Press SPACE to teleport! <<<")
        has_teleported = true
    elif shadow_aligned and not has_time_traveled:
        print("  >>> SHADOW ALIGNED! Press SPACE to time travel! <<<")
        has_time_traveled = true
    elif not is_aligned and not shadow_aligned:
        has_teleported = false
        has_time_traveled = false

func smoothstep(edge0, edge1, x):
    var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)

func lerp(a, b, t):
    return a + (b - a) * t
