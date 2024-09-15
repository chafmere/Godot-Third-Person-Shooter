extends OnGround

signal on_sprinting(active: bool)

func _state_input(_event :InputEvent) -> void:
	if _event.is_action_released("sprint"):
		finished.emit("Run")
	#update_direction.emit(Input.get_vector("left", "right", "up", "down"))
	
	return super._state_input(_event)

func _enter() -> void:
	on_sprinting.emit(true)
	animation_tree["parameters/state/transition_request"] = "sprint"

func _update(_delta: float) -> void:
	set_direction(Vector2(0,1))
	calculate_gravity(_delta)

	calculate_velocity(speed*MOVEMENT_STATS.sprint_speed_multiplier,direction,_delta)
	sprint_duration -= _delta
	if sprint_duration <= 0:
		finished.emit("Run")
		
	if direction == Vector3.ZERO:
		finished.emit("Idle")

func _exit() -> void:
	on_sprinting.emit(false)
