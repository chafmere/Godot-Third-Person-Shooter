extends Control

@onready var current_ammo: Label = %CurrentAmmo
@onready var reserve_ammo: Label = %ReserveAmmo


#func _on_weapon_manager_weapon_fired(weapon_slot: WeaponSlot) -> void:
	#current_ammo.set_text(str(weapon_slot.ammo.current_ammo))
#
#func _on_weapon_manager_weapon_reload_completed(ammo: AmmoResource) -> void:
	#reserve_ammo.set_text(str(ammo.reserve_ammo))
	#current_ammo.set_text(str(ammo.current_ammo))


func _on_weapon_manager_ammo_changed(ammo: AmmoResource) -> void:
	reserve_ammo.set_text(str(ammo.reserve_ammo))
	current_ammo.set_text(str(ammo.current_ammo))
