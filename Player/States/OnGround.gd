extends Motion
class_name OnGround

signal update_sprint_duration(duration: float)

static var sprint_duration: float = MOVEMENT_STATS.sprint_duration

func _state_input(_event :InputEvent) -> void:
	if _event.is_action_pressed("jump"):
		finished.emit("Jump")
	return

func replenish_sprint(delta: float) -> void:
	if sprint_duration == MOVEMENT_STATS.sprint_duration:
		return
	sprint_duration = clamp(sprint_duration+delta,0,MOVEMENT_STATS.sprint_duration)
	
