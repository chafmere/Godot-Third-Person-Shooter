extends StateMachine
@export var movement_stats: MovementStats
@export var animation_controller: Node3D


func _ready() -> void:
	for child in get_children():
		child.animation_state_updated.connect(animation_controller.on_state_machine_state_changed)
		child.direction_updated.connect(animation_controller.on_character_direction_changed)
		#child.animation_tree = animation_tree_player
	return super._ready()
