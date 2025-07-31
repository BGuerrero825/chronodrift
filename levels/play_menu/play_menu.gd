extends Control


@export var advanced_level : String = "res://levels/advanced_track.tscn"
@export var basic_level : String = "res://levels/basic_track_level.tscn"

func _on_play_pressed() -> void:
	print("pressed")
	get_tree().change_scene_to_file(advanced_level)

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file(basic_level)
