extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var camera: Camera3D = $Player/Camera3D
@onready var alignment_light: OmniLight3D = $Player/AlignmentLight
@onready var post_process: ColorRect = $CanvasLayer/PostProcess
@onready var shader_material: ShaderMaterial = post_process.material
@onready var audio_system: Node = $AudioSystem
@onready var shadow_system: Node = $ShadowSystem

# Room 1 - Wall Alignment
@onready var wall_near: MeshInstance3D = $Room1/Wall_Near
@onready var wall_far: MeshInstance3D = $Room1/Wall_Far

# Room 2 - Key-Lock Fusion
@onready var key_object: MeshInstance3D = $Room2/FusionKey
@onready var lock_object: MeshInstance3D = $Room2/FusionLock

# Level progression
var completed_room_1 = false
var completed_room_2 = false
var completed_room_3 = false

var alignment_intensity = 0.0
var fusion_intensity = 0.0
var shadow_alignment_intensity = 0.0
var is_aligned_wall = false
var is_aligned_fusion = false
var is_aligned_shadow = false

var move_speed = 6.0
var mouse_sensitivity = 0.0025
var camera_rotation = Vector2.ZERO

var teleport_cooldown = 0.0
var teleport_pulse = 0.0

var game_time = 0.0

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    print("")
    print("=============================================================")
    print("  DIMENSION HOPPER - DEMO LEVEL: THREE DOORS")
    print("=============================================================")
    print("")
    print("  Welcome. There are three doors.")
    print("  Each door teaches you a different way to see.")
    print("")
    print("  WASD - Move. Mouse - Look. SPACE - Activate.")
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
    
    shadow_alignment_intensity = shadow_system.get_alignment_intensity()
    is_aligned_shadow = shadow_system.is_aligned()
    
    # Update all shader parameters
    shader_material.set_shader_parameter("alignment_intensity", max(alignment_intensity, fusion_intensity))
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
    check_wall_alignment()
    check_fusion_alignment()
    update_visual_feedback(delta)
    
    if teleport_cooldown > 0:
        teleport_cooldown -= delta
    
    # Wall teleport - Room 1
    if is_aligned_wall and Input.is_action_just_pressed("ui_accept") and teleport_cooldown <= 0:
        if not completed_room_1:
            completed_room_1 = true
            open_door($Room1/Door1)
            print("")
            print("  ==================================================")
            print("  *   FIRST DOOR OPENED - YOU SEE SPACE          *")
            print("  ==================================================")
            print("")
        teleport_pulse = 1.0
        audio_system.trigger_teleport()
        teleport_cooldown = 1.5
    
    # Key-lock fusion - Room 2
    if is_aligned_fusion and Input.is_action_just_pressed("ui_accept") and teleport_cooldown <= 0:
        if not completed_room_2:
            completed_room_2 = true
            open_door($Room2/Door2)
            print("")
            print("  ==================================================")
            print("  *   SECOND DOOR OPENED - YOU SEE PERSPECTIVE   *")
            print("  ==================================================")
            print("")
        audio_system.trigger_fusion()
        teleport_cooldown = 1.5
    
    # Shadow time travel - Room 3
    if is_aligned_shadow and Input.is_action_just_pressed("ui_accept") and teleport_cooldown <= 0:
        if shadow_system.trigger_time_travel():
            audio_system.trigger_shadow_resonance()
            teleport_cooldown = 2.0
            
            if not completed_room_3:
                # Only unlock after first successful time travel
                completed_room_3 = true
                open_door($Room3/Door3)
                open_door($FinalGate/Gate)
                print("")
                print("  ==================================================")
                print("  *   THIRD DOOR OPENED - YOU SEE TIME           *")
                print("  ==================================================")
                print("")
                print("  All three paths are now one. You understand.")
                print("")

func handle_movement(delta):
    var input_dir = Input.get_vector("left", "right", "forward", "backward")
    var direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    player.velocity.x = direction.x * move_speed
    player.velocity.z = direction.z * move_speed
    player.move_and_slide()

func check_wall_alignment():
    var player_pos = player.global_position
    
    # Only check in Room 1 area (Z between 8 and 15)
    if player_pos.z < 8 or player_pos.z > 15 or completed_room_1:
        is_aligned_wall = false
        alignment_intensity = 0.0
        return
    
    var screen_near = camera.unproject_position(wall_near.global_position)
    var screen_far = camera.unproject_position(wall_far.global_position)
    
    var screen_distance = screen_near.distance_to(screen_far)
    var intensity = 1.0 - smoothstep(0.0, 150.0, screen_distance)
    
    alignment_intensity = intensity
    is_aligned_wall = intensity > 0.85

func check_fusion_alignment():
    var player_pos = player.global_position
    
    # Only check in Room 2 area (Z between -8 and 5)
    if player_pos.z < -8 or player_pos.z > 5 or completed_room_2:
        is_aligned_fusion = false
        fusion_intensity = 0.0
        return
    
    var screen_key = camera.unproject_position(key_object.global_position)
    var screen_lock = camera.unproject_position(lock_object.global_position)
    var screen_distance = screen_key.distance_to(screen_lock)
    
    var intensity = 1.0 - smoothstep(0.0, 40.0, screen_distance)
    fusion_intensity = intensity
    is_aligned_fusion = intensity > 0.9

func open_door(door):
    var collision = door.get_node("CollisionShape3D")
    collision.disabled = true
    
    var tween = create_tween()
    tween.tween_property(door, "position:y", door.position.y + 5.0, 2.0)
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_ELASTIC)

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

func smoothstep(edge0, edge1, x):
    var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)

func lerp(a, b, t):
    return a + (b - a) * t
