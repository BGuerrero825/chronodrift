extends AudioStreamPlayer3D


@onready var h_slider : HSlider = %HSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	var val := h_slider.value / 50

	pitch_scale = val




func _on_button_accel_pressed() -> void:
	playing = !playing


func _on_button_idle_pressed() -> void:
	playing = !playing

func _on_button_rocket_pressed() -> void:
	playing = !playing

func _on_button_bump_l_pressed() -> void:
	playing = !playing

func _on_button_bump_r_pressed() -> void:
	playing = !playing
