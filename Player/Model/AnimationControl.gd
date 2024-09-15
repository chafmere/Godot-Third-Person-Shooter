extends Node3D

signal change_weapon_finished
signal reload_finished

@onready var hip: Node3D = %HipTarget
@onready var hip_ik: SkeletonIK3D = %HipIK
@onready var left_hand_ik: SkeletonIK3D = %LeftHandIK
@onready var right_hand_attachment: Node3D = $RightHand/Attachment
@onready var left_hand_attachment: Node3D = $LeftHand/Attachment

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var shoot_timer: Timer = %ShootTimer


var next_weapon: PackedScene
var bullet_point: Marker3D
var ammmo_clip_to_load: PackedScene
var shooting: bool = false

func _ready() -> void:
	hip_ik.start()
	left_hand_ik.start()

func rotate_hip(rot: float) -> void:
	hip.transform.basis = Basis()
	hip.rotate_object_local(Vector3(1,0,0),rot)
	hip.rotate_object_local(Vector3(0,1,0),deg_to_rad(-50))

func hip_to_target(tar: Vector3) -> void:
	hip.look_at(tar)
	hip.rotate_object_local(Vector3(0,1,0),PI)

func set_ik_influence(skeleton_ik: SkeletonIK3D, active: bool, fade_time: float = .2) -> void:
	var target_influence : float = float(active)
	var target_tween : Tween = get_tree().create_tween()	
	target_tween.tween_property(skeleton_ik,"influence",target_influence,fade_time)

func _on_sprint_on_sprinting(active: bool) -> void:
	set_ik_influence(hip_ik,!active)

func attach_weapon_to_bone(weapon: PackedScene) -> void:
	
	remove_bone_attachment(right_hand_attachment)
	
	var new_attachment: WeaponModelAttachement = weapon.instantiate()
	right_hand_attachment.add_child(new_attachment)
	left_hand_ik.target_node = new_attachment.left_hand_target.get_path()
	bullet_point = new_attachment.bullet_point
	next_weapon = null
	
func remove_bone_attachment(bone_attachment: Node3D)-> void:
	if bone_attachment.get_child_count() > 0:
		var current_attachment: Node3D = bone_attachment.get_child(0)
	
		if bone_attachment:
			bone_attachment.queue_free()
	
func attach_to_left_hand() -> void:
	remove_bone_attachment(left_hand_attachment)
		
	var new_attachement: Node3D = ammmo_clip_to_load.instantiate()
	left_hand_attachment.add_child(new_attachement)

func remove_attachement_from_left_hand()-> void:
	var current_attachment: Node3D = left_hand_attachment.get_child(0)
	
	if current_attachment:
		current_attachment.queue_free()

func _on_weapon_manager_weapon_changed(weapon: WeaponResource) -> void:
	next_weapon = weapon.weapon_model
	set_ik_influence(left_hand_ik,false)
	animation_tree["parameters/change_weapon_trigger/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func load_new_mesh()-> void:
	set_ik_influence(left_hand_ik,true)
	attach_weapon_to_bone(next_weapon)

func change_weapon_complete() -> void:
	change_weapon_finished.emit(bullet_point)
	
func _on_camera_on_camera_rotated(rot: float) -> void:
	rotate_hip(rot)

func _on_camera_camera_targeted(target: Vector3) -> void:
	hip_to_target(target)

func _on_weapon_manager_weapon_reloaded(_weapon: WeaponResource) -> void:
	set_ik_influence(left_hand_ik,false)
	animation_tree["parameters/weeapon_reload/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	ammmo_clip_to_load = _weapon.ammo_clip
	
func reload_animation_finished()-> void:
	set_ik_influence(left_hand_ik,true)
	reload_finished.emit()

func activate_aim_blend() -> void:
	var blend_tween : Tween = create_tween()
	blend_tween.tween_property(animation_tree,"parameters/aim_blend/blend_amount",1,.1)

func deactivate_aim_blend() -> void:
	var blend_tween : Tween = create_tween()
	blend_tween.tween_property(animation_tree,"parameters/aim_blend/blend_amount",0,.2)

func _on_shoot_timer_timeout() -> void:
	shooting = false
	deactivate_aim_blend()

func _on_weapon_manager_weapon_fired(ammo: AmmoResource) -> void:
	if shooting == false:
		activate_aim_blend()
	shooting = true
	shoot_timer.start()
