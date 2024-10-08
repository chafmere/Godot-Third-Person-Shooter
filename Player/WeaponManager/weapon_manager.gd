extends Node3D
class_name WeaponManager

signal weapon_changed(weapon: WeaponResource, pick_up: WeaponPickUp)
signal weapon_reloaded(weapon: WeaponResource)
signal weapon_fired()
signal ammo_changed(ammo: AmmoResource)
#signal weapon_reload_completed(ammo: AmmoResource)

@export var weapon_slots: Array[WeaponSlot]
@export var animation_tree: AnimationMixer

var current_weapon_slot: WeaponSlot
enum WeaponState {UNAVAILABLE, READY}
var current_weapon_state: WeaponState = WeaponState.READY
var bullet_point: Marker3D

var shot_count: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_weapon(0)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_up"):
		var weapon_index: int = weapon_slots.find(current_weapon_slot)
		weapon_index = (weapon_index+1) % (weapon_slots.size())
		change_weapon(weapon_index)
		
	if event.is_action_released("weapon_down"):
		var weapon_index: int = weapon_slots.find(current_weapon_slot)
		weapon_index = max(weapon_index-1,0)
		change_weapon(weapon_index)
		
	if event.is_action_pressed("shoot"):
		_shoot()
		
	if event.is_action_pressed("reload"):
		_reload()
		
	if event.is_action_pressed("drop"):
		_drop()

func _process(delta: float) -> void:
	shot_count_update(delta)

func change_weapon(weapon_index: int, weapon_to_drop: WeaponPickUp = null) -> void:
	if weapon_slots[weapon_index] == current_weapon_slot:
		return
		
	if current_weapon_state == WeaponState.READY:
		change_state(WeaponState.UNAVAILABLE)
		current_weapon_slot = weapon_slots[weapon_index]
		weapon_changed.emit(current_weapon_slot.weapon,weapon_to_drop)

func change_state(state: WeaponState) -> void:
	current_weapon_state = state

func _on_test_character_change_weapon_finished(bp : Marker3D) -> void:
	change_state(WeaponState.READY)
	bullet_point = bp

func update_ui() -> void:
	ammo_changed.emit(current_weapon_slot.ammo)

func _shoot() -> void:
	if current_weapon_state == WeaponState.READY:
		#if current_weapon_slot.weapon.has_ammo:
		if current_weapon_slot.weapon.has_ammo == false:
			fire_weapon()
			weapon_fired.emit()
			
		elif current_weapon_slot.ammo.current_ammo > 0:
			current_weapon_slot.ammo.current_ammo -= 1
			weapon_fired.emit()
			ammo_changed.emit(current_weapon_slot.ammo)
			fire_weapon()
		else:
			_reload()
			
func fire_weapon()-> void:
	load_projectile(current_weapon_slot)
	change_state(WeaponState.UNAVAILABLE)
	get_tree().create_timer(current_weapon_slot.weapon.fire_rate).timeout.connect(finished_firing)

func _reload() -> void:
	if current_weapon_slot.ammo.current_ammo == current_weapon_slot.ammo.magazine_capacity or current_weapon_slot.ammo.reserve_ammo == 0 or !current_weapon_slot.weapon.has_ammo:
		return
		
	change_state(WeaponState.UNAVAILABLE)
	weapon_reloaded.emit(current_weapon_slot.weapon)

func _drop() -> void:
	var weapon_to_drop: WeaponPickUp = current_weapon_slot.weapon.weapon_to_drop.instantiate()
	weapon_to_drop.weapon_slot = current_weapon_slot
	
	var weapon_index: int = weapon_slots.find(current_weapon_slot)
	weapon_slots.remove_at(weapon_index)
	
	weapon_index = max(weapon_index-1,0)
	
	change_weapon(weapon_index, weapon_to_drop)

func finished_firing() -> void:
	change_state(WeaponState.READY)
	if current_weapon_slot.weapon.auto_fire and Input.is_action_pressed("shoot"):
		_shoot()

func shot_count_update(_delta: float) -> void:
	if current_weapon_state == WeaponState.READY:
		if shot_count > 0:
			shot_count -= 1

func load_projectile(weapon_slot: WeaponSlot) -> void:
	var _proj: Projectile = weapon_slot.weapon.projectile_to_load.instantiate()
	bullet_point.add_child(_proj)
	_proj.set_owner(bullet_point)
	_proj.global_position = bullet_point.global_position
	_proj.global_rotation = bullet_point.global_rotation
	
	shot_count += 1
	var spray_vector: Vector2
	if weapon_slot.weapon.weapon_spray:
		spray_vector = weapon_slot.weapon.weapon_spray.Get_Spray(shot_count,weapon_slot.ammo.magazine_capacity)
	
	_proj._set_projectile(weapon_slot.weapon.damage, spray_vector)

func _on_reload_finished() -> void:
	change_state(WeaponState.READY)
	calculate_reload()
	
func calculate_reload() -> void:
	var reload_amount: int = min(current_weapon_slot.ammo.magazine_capacity - current_weapon_slot.ammo.current_ammo,
			current_weapon_slot.ammo.reserve_ammo,
			current_weapon_slot.ammo.magazine_capacity)
	current_weapon_slot.ammo.current_ammo += reload_amount
	current_weapon_slot.ammo.reserve_ammo -= reload_amount
	ammo_changed.emit(current_weapon_slot.ammo)

func _on_sprint_on_sprinting(active: bool) -> void:
	if active:
		change_state(WeaponState.UNAVAILABLE)
	else:
		change_state(WeaponState.READY)
