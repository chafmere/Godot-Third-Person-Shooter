extends Area3D
class_name DamageArea

signal on_damage(_damage: float)

@export var damage_multiplier : float = 1.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func hit_successful(damage: float) -> void:
	var gross_damage: float = damage * damage_multiplier
	on_damage.emit(gross_damage)

func _on_body_entered(body: Node3D) -> void:
	if body is RigidBodyBullet:
		hit_successful(body.damage)
		body.queue_free()

func _on_area_entered(area: Node3D)-> void:
	if area is DamageZone:
		hit_successful(area.damage)
		area.queue_free()
