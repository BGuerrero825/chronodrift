extends Node

@onready var menu: AudioStreamPlayer = %MenuMusic
@onready var gameplay: AudioStreamPlayer = %GameplayMusic


func play_menu_music() -> void:
	if not menu.playing:
		menu.play()


func play_gameplay_music() -> void:
	if not gameplay.playing:
		fade_in(gameplay)


func fade_in(music: AudioStreamPlayer) -> void:
	music.volume_db = -30
	music.play()
	var tween := create_tween()
	tween.tween_property(music, "volume_db", 0, 2)
