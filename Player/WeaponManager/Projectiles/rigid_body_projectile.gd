extends Projectile
class_name RigidBodyProjectile

@export var projectile_velocity: int
@export var expirey_time: int = 10
@export var rigid_body_projectile: PackedScene

func _ready() -> void:
	get_tree().create_timer(expirey_time).timeout.connect(_on_timer_timeout)

func _fire_projectile(_spread: Vector2 ,_range: int) -> void:
	var camera_collision: Array = _camera_ray_cast(_spread)
	launch_rigid_body_projectile(camera_collision,rigid_body_projectile)
	
func launch_rigid_body_projectile(collision_data: Array, _projectile: PackedScene) -> void:
	var _Point: Vector3 = collision_data[1]
	var _Norm: Vector3 = collision_data[2]
	var _proj : RigidBodyBullet = _projectile.instantiate()
	
	_proj.top_level = true
	_proj.position = global_position

	add_child(_proj)
	_proj.look_at(_Point)
	_proj.damage = damage

	_proj.body_entered.connect(_on_body_entered.bind(_proj,_Norm))
	
	var _direction: Vector3 = (_Point - global_position).normalized()
	_proj.set_linear_velocity(_direction*projectile_velocity)
	
func _on_body_entered(body: Node3D, projectile: RigidBody3D, normal: Vector3) -> void:
	if body is DamageArea:
		body.hit_successful(damage)
	queue_free()
	
func _on_timer_timeout() -> void:
	queue_free()
