extends Resource
class_name SprayProfile

@export_category("Random_Spray")
@export var spray_noise: FastNoiseLite
@export_range(0.0,10.0) var random_spray_multiplier: float = 1.0
@export_range(1,10) var base_heat: float = 1
@export_range(0,100) var max_limit: float = 30
@export var updwards_lock: bool = false
@export var True_Random: bool = true

var Random_Spray: Vector2 = Vector2.ZERO
var Spray_Vector: Vector2 = Vector2.ZERO

func Get_Spray(count: float,_max_count: int)->Vector2:
	if spray_noise:
		if True_Random:
			spray_noise.set_seed(randi())
		
		var heat: float = min(pow(base_heat, count),max_limit)
		
		var x : float = spray_noise.get_noise_1d(randi())*heat
		var y : float = spray_noise.get_noise_1d(randi())*heat

		if updwards_lock:
			y = -abs(y)
			
		Random_Spray = Vector2(x,y)*random_spray_multiplier

	return Random_Spray
