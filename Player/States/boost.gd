extends InAir

var boost_accelleration: float = 100.00
var max_boost_speed: float = 3

func _state_input(_event :InputEvent) -> void:
	if _event.is_action_released("jump"):
		finished.emit("Fall")

func _enter() -> void:
	animation_tree["parameters/state/transition_request"] = "jump_idle"

func _update(_delta: float) -> void:
	boost_amount -= _delta
	if boost_amount <= 0:
		finished.emit("Fall")
		
	set_direction()
	boost(_delta)
	calculate_velocity(speed,direction,_delta)
	

func boost(delta: float)-> void:
	velocity.y = move_toward(velocity.y, max_boost_speed,boost_accelleration*delta)
