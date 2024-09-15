extends Node
class_name StateMachine

signal on_state_changed(current_state: Node)

@export var start_state: State
var state_map: Dictionary
var current_state: State = null
var _active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_state_map()
	initialize(start_state)

func create_state_map() -> void:
	for child: State in get_children():
		child.finished.connect(change_state)
		state_map[child.name] = child

func initialize(state: State) -> void:
	set_active(true)
	current_state = state
	current_state._enter()

func set_active(value: bool) -> void:
	_active = value
	set_physics_process(value)
	set_process_input(value)
	if not _active:
		current_state = null

func _input(event: InputEvent) -> void:
	current_state._state_input(event)
	
func _physics_process(delta: float) -> void:
	current_state._update(delta)

func change_state(state_name: String) -> void:
	if not _active:
		return
		
	current_state._exit()
	
	current_state  = state_map[state_name]
	current_state._enter()
	on_state_changed.emit(current_state)
