extends Control

@export var slowest_r: float
@export var fastest_r: float
@export var slowest_g: float
@export var fastest_g: float
@export var slowest_b: float
@export var fastest_b: float
var throttle: float = 0.5
var speed_ratio: float = 0.5
var ship: PlayerShip

@onready var speed_bar: ColorRect = %SpeedBar
@onready var throttle_bar: ColorRect = %ThrottleBar


func _process(_delta: float) -> void:
	if not ship:
		ship = EventsBus.get_player_ref()
		return
	# Set throttle bar color / fill
	throttle = lerp(throttle, ship.throttle, 0.15)
	throttle_bar.material.set("shader_parameter/filled_color", get_fill_color(throttle))
	throttle_bar.material.set("shader_parameter/fade_fill_amount", throttle)

	# Set speed bar color / fill
	speed_ratio = ship.current_speed / ship.ground_max_speed
	speed_bar.material.set("shader_parameter/filled_color", get_fill_color(speed_ratio))
	speed_bar.material.set("shader_parameter/fade_fill_amount", speed_ratio)


func get_fill_color(ratio: float) -> Color:
	var color := Color(1, 1, 1, 1)
	color.r = calculate_color_portion(slowest_r, fastest_r, ratio)
	color.g = calculate_color_portion(slowest_g, fastest_g, ratio)
	color.b = calculate_color_portion(slowest_b, fastest_b, ratio)
	return color
	

func calculate_color_portion(slow: float, fast: float, ratio: float) -> float:
	return slow + ((fast - slow) * ratio)
