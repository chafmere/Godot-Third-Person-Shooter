extends CharacterBody3D

@export var health: float = 100


func _on_damage_area_on_damage(_damage: float) -> void:
	reduce_health(_damage)

func reduce_health(amt: float) -> void:
	health -= amt
	if health <= 0:
		queue_free()
