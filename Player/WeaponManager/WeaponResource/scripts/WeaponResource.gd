extends Resource
class_name WeaponResource

@export_group("Weapon")
@export var weapon_name: String
@export var weapon_model: PackedScene


@export_group("Weapon Stats")
## If Uncheck Shoot Function Will skip ammo check
@export var has_ammo: bool = true
## The Maximum amount that you will reload if zero
#@export var magazine: int
## The Maximum ammo that can be held in reserve.
@export var max_ammo: int
## The damage that a weapon will do
@export var damage: int
## If Auto Fire is set to true the weapon will continuously fire until fire trigger is released
@export var auto_fire: bool
## The Range that a weapon will fire. Beyong this number no hit will trigger.
@export var fire_range: int
@export var fire_rate: float = .3

@export_group("Weapon Behaviour")
@export_enum("pistol", "rifle", "melee") var weapon_state: String
##If Checked the weapon drop scene MUST be provided
@export var can_be_dropped: bool
## The Rigid body to spawn for the weapon. It should be a Rigid Body of type Weapon_Pick_Up and have a matching weapon_name.
@export var weapon_to_drop: PackedScene
## The Spray_Profile to use when firing the weapon. It should be of Type Spray_Profile. This handles the spray calculations and passes back the information to the Projectile to load
@export var weapon_spray: SprayProfile
## The Projectile that will be loaded. Not a Rigid body but class that handles the ray cast processing and can be either hitscan or rigid body. Should be of Type Projectile
@export var projectile_to_load: PackedScene
## Incremental Reload is for shotgun or sigle item loaded weapons where you can interupt the reload process. If true the Calculate_Reload function on the weapon_state_machine must be called indepently. 
## For Example: at each step of a shotgun reload the function is called via the animation player.
@export var incremental_reload: bool = false
@export var ammo_clip: PackedScene
