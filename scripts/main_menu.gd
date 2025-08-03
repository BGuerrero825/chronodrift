class_name MainMenu
extends Control

@onready var play_1: Button = %PlayButton
@onready var play_2: Button = %PlayButton2
@onready var settings_button: Button = %Settings


func _ready() -> void:
	var play_buttons: Array[Button] = [play_1, play_2]
	for button in play_buttons:
		button.pressed.connect(queue_free)
	play_1.grab_focus()
