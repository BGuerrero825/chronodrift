extends HSlider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = Options.sfx_volume


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	Options.sfx_volume = value
	AudioServer.set_bus_volume_db(2, Options.convert_percentage_to_decibels(value))
