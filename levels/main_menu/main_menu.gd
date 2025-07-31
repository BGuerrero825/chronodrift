extends Control

func _ready() -> void:
	HUD.update_speedometer(0, true)

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/options_menu/options_menu.tscn")


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/play_menu/play_menu.tscn")

