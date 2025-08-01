extends Node

@onready var menu: AudioStreamPlayer = %MenuMusic
@onready var gameplay: AudioStreamPlayer = %GameplayMusic


func play_menu_music() -> void:
	if not menu.playing:
		menu.play()


func play_gameplay_music() -> void:
	if not gameplay.playing:
		gameplay.play()
