extends CharacterBody3D

@onready var state_label: Label3D = $StateLabel


func _set_velocity_from_motion(vel: Vector3) -> void:
	velocity = vel

func _input(event: InputEvent) -> void:
	pass

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _on_movement_state_machine_on_state_changed(current_state: Node) -> void:
	state_label.set_text("STATE: "+ current_state.name)

func check_for_impending_landing()->Dictionary:
	var pos: Vector3 = global_position
	var pos_end: Vector3  = pos
	pos_end.y = pos.y + -1
	
	var ray:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(pos,pos_end)
	ray.exclude = [get_rid()]
	var intersection: Dictionary = get_world_3d().direct_space_state.intersect_ray(ray)

	if not intersection.is_empty():
		var _collision: Vector3 = intersection.position

	return intersection
