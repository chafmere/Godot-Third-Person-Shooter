extends OnGround


func _state_input(_event :InputEvent) -> void:
	if _event.is_action_pressed("sprint"):
		if input_dir == Vector2(0,1) or input_dir == Vector2(1,0) or input_dir == Vector2(-1,0):
			return
		finished.emit("Sprint")
	return super._state_input(_event)

func _enter()->void:
	animation_state_updated.emit("run")
	#animation_tree["parameters/state/transition_request"] = "run"
	#animation_tree["parameters/pistol_blend/blend_amount"] = 1.0

func _update(_delta: float) -> void:
	set_direction()
	calculate_gravity(_delta)
	replenish_sprint(_delta/2)
	calculate_velocity(speed,direction,_delta)

	if direction == Vector3.ZERO:
		finished.emit("Idle")
		
	if !check_floor():
		finished.emit("Fall")

func _exit() -> void:
	return
