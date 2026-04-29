extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var camera: Camera3D = $Player/Camera3D
@onready var alignment_light: OmniLight3D = $Player/AlignmentLight

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

var move_speed = 6.0
var mouse_sensitivity = 0.0025
var camera_rotation = Vector2.ZERO

var has_teleported = false
var teleport_cooldown = 0.0
var fusion_cooldown = 0.0

func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    print("")
    print("=============================================================")
    print("  DIMENSION HOPPER - PROTOTYPE v0.2")
    print("=============================================================")
    print("")
    print("  TWO KNOWLEDGE LOCK MECHANISMS:")
    print("")
    print("  1. EDGE ALIGNMENT - Two walls become one in your view")
    print("  2. PERSPECTIVE FUSION - Key and lock merge in your view")
    print("")
    print("  CONTROLS:")
    print("    WASD  - Move")
    print("    MOUSE - Look around")
    print("    SPACE - Activate when aligned")
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

func _physics_process(delta):
    handle_movement(delta)
    check_edge_alignment()
    check_perspective_fusion()
    update_visual_feedback(delta)
    
    if teleport_cooldown > 0:
        teleport_cooldown -= delta
    if fusion_cooldown > 0:
        fusion_cooldown -= delta
    
    if is_aligned and Input.is_action_just_pressed("ui_accept") and teleport_cooldown <= 0:
        perform_teleport()
    
    if is_fused and Input.is_action_just_pressed("ui_accept") and fusion_cooldown <= 0:
        perform_fusion()

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
    print("  **************************************************")
    print("  *   DIMENSION HOP - TELEPORT SUCCESSFUL!        *")
    print("  **************************************************")
    print("")
    
    player.global_position = teleport_target.global_position
    teleport_cooldown = 1.5
    camera.reset_smoothing()

func perform_fusion():
    print("")
    print("  **************************************************")
    print("  *   PERSPECTIVE FUSION - DOOR UNLOCKED!         *")
    print("  **************************************************")
    print("")
    
    door_opened = true
    door_collision.disabled = true
    
    var tween = create_tween()
    tween.tween_property(fusion_door, "position:y", fusion_door.position.y + 4.0, 1.5)
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_ELASTIC)
    
    fusion_cooldown = 1.0

func update_visual_feedback(delta):
    var target_energy = 0.5 + alignment_intensity * 8.0 + fusion_intensity * 6.0
    alignment_light.light_energy = move_toward(alignment_light.light_energy, target_energy, delta * 20.0)
    
    if alignment_intensity > 0.3 or fusion_intensity > 0.3:
        var shake_x = randf_range(-1, 1) * max(alignment_intensity, fusion_intensity) * 2.5
        var shake_y = randf_range(-1, 1) * max(alignment_intensity, fusion_intensity) * 2.5
        camera.position = Vector3(shake_x * 0.006, shake_y * 0.006, 0)
    else:
        camera.position = Vector3.ZERO
    
    if is_aligned and not has_teleported:
        print("  >>> WALLS ALIGNED! Press SPACE to teleport! <<<")
        has_teleported = true
    elif not is_aligned:
        has_teleported = false

func smoothstep(edge0, edge1, x):
    var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)

func move_toward(from, to, delta):
    if abs(to - from) <= delta:
        return to
    return from + sign(to - from) * delta
