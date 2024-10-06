extends InAir

func _enter() -> void:
	pass
	#animation_state_updated.emit("jump")
	#animation_tree["parameters/state/transition_request"] = "jump_idle"

func _update(_delta: float) -> void:
	set_direction()
	calculate_gravity(_delta)
	calculate_velocity(speed,direction,_delta)
	
	if owner.check_for_impending_landing():
		animation_state_updated.emit("idle")
		#animation_tree["parameters/state/transition_request"] = "jump_land"
	
	if check_floor():
		boost_amount = max_boost
		if direction != Vector3.ZERO:
			finished.emit("Run")
		else:
			finished.emit("Idle")

func _exit() -> void:
	pass
