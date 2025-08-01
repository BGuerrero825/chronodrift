class_name MainMenu
extends Control

@onready var play_1: Button = %PlayButton
@onready var play_2: Button = %PlayButton2
@onready var play_3: Button = %PlayButton3


func _ready() -> void:
	MusicManager.play_menu_music()

	var play_buttons: Array[Button] = [play_1, play_2, play_3]
	for button in play_buttons:
		button.pressed.connect(queue_free)
