extends Node3D

var max_lifetime = 1.0
var min_lifetime = 0.3
var max_z_scale = 0.4
var min_z_scale = 0.2
var ship: PlayerShip

@onready var main_thruster: GPUParticles3D = %MainThruster


func throttle_updated(throttle: float) -> void:
	# Set thruster lifetime
	main_thruster.lifetime = _get_ratiod_value(min_lifetime, max_lifetime, throttle)

	# Set thruster length
	var curvexyz: CurveXYZTexture = main_thruster.process_material.scale_curve
	curvexyz.curve_z.set_point_value(0, _get_ratiod_value(min_z_scale, max_z_scale, throttle))


func speed_updated(_speed: float) -> void:
	pass


func _get_ratiod_value(low: float, high: float, ratio: float) -> float:
	ratio = clampf(ratio, 0, 1)
	return ((high - low) * ratio) + low
