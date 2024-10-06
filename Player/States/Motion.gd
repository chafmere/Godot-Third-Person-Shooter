extends State

class_name Motion

signal on_velocity_updated(_vel: Vector3)
signal direction_updated(dir: Vector2)
signal animation_state_updated(state: String)

static var direction: Vector3 = Vector3.ZERO
static var velocity: Vector3 = Vector3.ZERO
static var animation_tree: AnimationTree
static var input_dir: Vector2 = Vector2.ZERO

var jump_gravity: float
var fall_gravity: float
var jump_velocity: float

var speed: float
var max_speed: float
var direction_blend: Vector2
static var _speed_blend: Vector2

const MOVEMENT_STATS: MovementStats = preload("res://Player/States/movement_stats.tres")

func _ready() -> void:
	on_velocity_updated.connect(owner._set_velocity_from_motion)
	set_gravity()
	set_speed()

func set_gravity()-> void:
	jump_gravity = (2 * MOVEMENT_STATS.jump_height)/ pow(MOVEMENT_STATS.time_to_jump_apex,2)
	fall_gravity = (2 * MOVEMENT_STATS.jump_height)/ pow(MOVEMENT_STATS.time_to_land,2)
	jump_velocity = (jump_gravity*MOVEMENT_STATS.time_to_jump_apex)

func set_speed()-> void:
	speed = MOVEMENT_STATS.jump_distance/(MOVEMENT_STATS.time_to_jump_apex+MOVEMENT_STATS.time_to_land)
	max_speed = speed*MOVEMENT_STATS.sprint_speed_multiplier

func set_direction(turn_rate: Vector2 = Vector2(1,1))-> void:
	input_dir = Input.get_vector("left", "right", "up", "down")*turn_rate
	direction = (owner.transform.basis * Vector3(input_dir.x, 0,input_dir.y)).normalized()
	##TODO Convert to signal
	#if animation_tree:
	direction_blend.x = move_toward(direction_blend.x,input_dir.x,.05)
	direction_blend.y = move_toward(direction_blend.y,input_dir.y,.05)
	direction_updated.emit(direction_blend)

func calculate_velocity(_speed: float, _direction: Vector3, delta: float) -> void:
	velocity.x = move_toward(velocity.x, _direction.x*_speed,MOVEMENT_STATS.acceleration*delta)
	velocity.z = move_toward(velocity.z, _direction.z*_speed,MOVEMENT_STATS.acceleration*delta)
	on_velocity_updated.emit(velocity)

func calculate_gravity(delta: float)->void:
	if jump_gravity == null:
		return
	if !owner.is_on_floor():
		if velocity.y>0:
			velocity.y -= jump_gravity*delta
		else:
			velocity.y -= fall_gravity*delta

func check_floor()->bool:
	return owner.is_on_floor()
