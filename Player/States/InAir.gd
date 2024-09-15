extends Motion
class_name InAir

static var boost_amount: float = 1
static var gravity_blend: float
var max_boost: float = 1

func _state_input(_event :InputEvent) -> void:
	if _event.is_action_pressed("jump"):
		finished.emit("Boost")
	return
