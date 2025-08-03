extends Node

var full_screen := false
var master_volume: float = 50
var sfx_volume: float = 50
var music_volume: float = 50


func set_volume_for_bus(bus_name: String) -> void:
	var value: float = 50
	match bus_name:
		"Master":
			value = master_volume
		"SFX":
			value = sfx_volume
		"Music":
			value = music_volume
		_:
			push_error("Tried to change volume for bus that does not exist: ", bus_name)
			return

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), convert_percentage_to_decibels(value))


func convert_percentage_to_decibels(percent: float) -> float:
	var scale : float = 20.0
	var divisor : float = 50.0
	return scale * log(percent / divisor) / log(10)
