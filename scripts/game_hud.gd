extends Control

@export var slowest_r: float
@export var fastest_r: float
@export var slowest_g: float
@export var fastest_g: float
@export var slowest_b: float
@export var fastest_b: float
var amount: float = 0.5
var ship: PlayerShip

@onready var speed_bar: ColorRect = %SpeedBar


func _process(_delta: float) -> void:
	if not ship:
		ship = EventsBus.get_player_ref()
		return
	amount = ship.current_speed / ship.ground_max_speed
	speed_bar.material.set("shader_parameter/filled_color", get_fill_color())
	speed_bar.material.set("shader_parameter/fade_fill_amount", amount)


func get_fill_color() -> Color:
	var color := Color(1, 1, 1, 1)
	color.r = calculate_color_portion(slowest_r, fastest_r)
	color.g = calculate_color_portion(slowest_g, fastest_g)
	color.b = calculate_color_portion(slowest_b, fastest_b)
	return color
	

func calculate_color_portion(slow: float, fast: float) -> float:
	return slow + ((fast - slow) * amount)
