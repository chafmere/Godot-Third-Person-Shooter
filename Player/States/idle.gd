extends OnGround


func _enter()->void:
	animation_tree["parameters/state/transition_request"] = "idle"

func _update(_delta: float) -> void:
	set_direction()
	calculate_gravity(_delta)
	calculate_velocity(speed,direction,_delta)
	replenish_sprint(_delta)
	
	if direction != Vector3.ZERO:
		finished.emit("Run")
