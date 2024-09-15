extends Node3D
class_name  Projectile

var damage: float = 0
@export var display_debug_decal: bool = true

func _set_projectile(_damage: int = 0,_spread:Vector2 = Vector2.ZERO, _range: int = 1000) -> void:
	damage = _damage
	_fire_projectile(_spread,_range)
	
func _fire_projectile(_spread: Vector2 ,_range: int) -> void:
	pass

func _camera_ray_cast(_spread: Vector2 = Vector2.ZERO, _range: float = 1000) -> Array:
	var viewport : Vector2i
	var window: Window = get_window()
	
	match window.content_scale_mode:
		window.CONTENT_SCALE_MODE_VIEWPORT:
			viewport = window.content_scale_size
		window.CONTENT_SCALE_MODE_CANVAS_ITEMS:
			viewport = window.content_scale_size
		window.CONTENT_SCALE_MODE_DISABLED:
			viewport = window.get_size()

	var camera : Camera3D = get_viewport().get_camera_3d()

	var ray_origin : Vector3 = camera.project_ray_origin(viewport/2)
	var ray_end: Vector3 = (ray_origin + camera.project_ray_normal((viewport/2)+Vector2i(_spread))*_range)
	var new_ray_query:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin,ray_end)
	new_ray_query.set_collision_mask(0b11110111)
	new_ray_query.set_hit_from_inside(false) # In Jolt this is set to true by defualt
	
	var intersection: Dictionary = get_world_3d().direct_space_state.intersect_ray(new_ray_query)
	
	if not intersection.is_empty():
		var Collision : Array = [intersection.collider,intersection.position,intersection.normal]
		return Collision
	else:
		return [null,ray_end,Vector3.ZERO]

func _load_debug_decal(_pos: Vector3,_normal: Vector3, _decal: PackedScene) -> void:
	if display_debug_decal:
		var rd: Node3D = _decal.instantiate()
		var world: Window = get_tree().get_root()
		world.add_child(rd)
		rd.global_translate(_pos+(_normal*.01))
