extends InAir

#wait one frame before checking the ground to give us enough time to leave the ground
var check_jump: bool = false
var timeout: float = .02
var time: float = 0

func _enter()->void:
	animation_state_updated.emit("jump")
	#animation_tree["parameters/state/transition_request"] = "jump"
	jump()

func _update(_delta: float) -> void:
	set_direction()
	calculate_gravity(_delta)
	calculate_velocity(speed,direction,_delta)
	
	if velocity.y <= 0:
		finished.emit("Fall")
	
func _exit() -> void:
	time = 0
	check_jump = false

func jump()-> void:
	velocity.y = jump_velocity
	
