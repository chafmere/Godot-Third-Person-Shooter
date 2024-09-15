extends Node3D

signal on_camera_rotated(rot: float)
signal camera_targeted(target: Vector3)

@export var character: CharacterBody3D
@export var character_collider: CollisionShape3D
@export var aim_spring_length: float  = .5
@export var aim_side_spring_length: float = .8
@export var aim_speed: float = .2
@export var aim_fov: float = 30
@export var sprint_increase_fov: float = 15
@export var camera: Camera3D
@export var over_head_spring_arm: SpringArm3D
@export var side_spring_arm: SpringArm3D
@export var sprint_turn_rate: float = .02

var aiming: bool = false
var sprinting: bool = false
var starting_spring_length: float
var camera_rotation: Vector2 = Vector2(0.0,0.0)
var mouse_sensitivity: float = 0.001
var side_spring_arm_legnth: float
var aiming_tween: Tween
var sprint_tween: Tween
var default_fov: float


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	default_fov = camera.fov
	starting_spring_length = over_head_spring_arm.spring_length
	side_spring_arm_legnth = side_spring_arm.spring_length
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event.is_action_pressed("camera_switch"):
		set_camera_alignment()
	
	if event is InputEventMouseMotion:
		var MouseEvent: Vector2 = event.screen_relative * mouse_sensitivity
		if sprinting:
			MouseEvent.x = sign(MouseEvent.x) * sprint_turn_rate
		camera_look(MouseEvent)
	
	if event.is_action_pressed("aim") and not aiming:
		enter_aiming()
	if event.is_action_released("aim") and aiming:
		exit_aiming()

func _process(_delta: float) -> void:
	if sprinting:
		var turn_axis: float = Input.get_axis("left", "right")
		camera_look(Vector2(turn_axis*sprint_turn_rate,0))
	camera_targeted.emit(get_camera_target())

func set_camera_alignment()-> void:
	side_spring_arm_legnth = side_spring_arm_legnth * -1
	var new_pos: float
	if aiming:
		new_pos = aim_side_spring_length*sign(side_spring_arm_legnth)
	else:
		new_pos = side_spring_arm_legnth
	align_camera(new_pos)

func set_camera_centre() -> void:
	align_camera(0)

func align_camera(pos: float) -> void:
	var new_tween: Tween = get_tree().create_tween()
	new_tween.tween_property(side_spring_arm, "spring_length",pos,.1)

func camera_look(movement: Vector2) -> void:
	camera_rotation += movement
	
	character.transform.basis = Basis()
	transform.basis = Basis()
	
	character.rotate_object_local(Vector3(0,1,0),-camera_rotation.x) # first rotate in Y
	rotate_object_local(Vector3(1,0,0), -camera_rotation.y) # then rotate in X
	camera_rotation.y = clamp(camera_rotation.y,-1.2,1.5)
	on_camera_rotated.emit(camera_rotation.y)
	
func get_camera_target() -> Vector3:
	var viewport_size: Vector2i = get_viewport().get_size()
	var ray_origin: Vector3 = camera.project_ray_origin(viewport_size/2)
	
	var ray_end:Vector3 = ray_origin + camera.project_ray_normal(viewport_size/2)*100
	
	var ray:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin,ray_end)
	ray.exclude = [character.get_rid()]
	var intersection: Dictionary = get_world_3d().direct_space_state.intersect_ray(ray)
	
	if not intersection.is_empty():
		var collision: Vector3 = intersection.position
		return collision
	else:
		return ray_end

func enter_aiming() -> void:
	if sprinting:
		return
		
	aiming = true
	
	if aiming_tween:
		aiming_tween.kill()
		
	aiming_tween = get_tree().create_tween()
	aiming_tween.set_parallel(true)
	aiming_tween.set_trans(Tween.TRANS_EXPO)
	aiming_tween.set_ease(Tween.EASE_OUT)
	aiming_tween.tween_property(camera,"fov",aim_fov,aim_speed)
	aiming_tween.tween_property(over_head_spring_arm, "spring_length",aim_spring_length,aim_speed)
	aiming_tween.tween_property(side_spring_arm, "spring_length",aim_side_spring_length*(sign(side_spring_arm_legnth)),aim_speed)
	
func exit_aiming() -> void:
	aiming = false
	if aiming_tween:
		aiming_tween.kill()
		
	aiming_tween = get_tree().create_tween()
	aiming_tween.set_parallel(true)
	aiming_tween.set_trans(Tween.TRANS_EXPO)
	aiming_tween.set_ease(Tween.EASE_OUT)
	aiming_tween.tween_property(camera,"fov",default_fov,aim_speed)
	aiming_tween.tween_property(over_head_spring_arm, "spring_length",starting_spring_length,aim_speed)
	aiming_tween.tween_property(side_spring_arm, "spring_length",side_spring_arm_legnth,aim_speed)
	
func _on_body_detection_body_entered(_body: Node3D) -> void:
	character.visible = false

func _on_body_detection_body_exited(_body: Node3D) -> void:
	character.visible = true

func on_sprint(fov: float) -> void:
	if sprint_tween:
		sprint_tween.kill()
	
	exit_aiming()
	sprint_tween = get_tree().create_tween()
	sprint_tween.set_parallel()
	sprint_tween.set_trans(Tween.TRANS_EXPO)
	sprint_tween.set_ease(Tween.EASE_OUT)
	sprint_tween.tween_property(camera,"fov",fov,1)

func _on_sprint_on_sprinting(active: bool) -> void:
	sprinting = active
	on_sprint(default_fov+(sprint_increase_fov*int(sprinting)))

func _on_sprint_update_direction(dir: Vector2) -> void:
	print(dir)
