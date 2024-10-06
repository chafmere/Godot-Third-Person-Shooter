extends Projectile

@export var melee_strike_area: RigidBodyBullet
@export var strike_delay: float = .2
@export var strike_timeout: float = 1.3

func _fire_projectile(_spread: Vector2 ,_range: int) -> void:
	melee_strike_area.damage = damage
	get_tree().create_timer(strike_delay).timeout.connect(set_strike)
	get_tree().create_timer(strike_timeout).timeout.connect(remove_melee_strike)

func set_strike()->void:
	melee_strike_area.set_collision_layer_value(4,true)
	melee_strike_area.set_collision_mask_value(4,true)
#
func remove_melee_strike()-> void:
	queue_free()
