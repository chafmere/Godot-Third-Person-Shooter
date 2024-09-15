extends StateMachine
@export var movement_stats: MovementStats
@export var animation_tree_player: AnimationTree


func _ready() -> void:
	for child in get_children():
		child.animation_tree = animation_tree_player
	return super._ready()
