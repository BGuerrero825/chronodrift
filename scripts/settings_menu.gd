class_name SettingsMenu
extends Control

@onready var exit_button: Button = %ExitButton
@onready var master_volume: HSlider = %MasterVolumeSlider
@onready var sfx_volume: HSlider = %SFXVolumeSlider
@onready var music_volume: HSlider = %MusicVolumeSlider
@onready var fullscreen: Button = %FullscreenButton


func _ready() -> void:
	get_tree().paused = true
	tree_exiting.connect(_on_leaving_tree)

	master_volume.value = Settings.master_volume
	master_volume.value_changed.connect(_on_master_volume_changed)
	sfx_volume.value = Settings.sfx_volume
	sfx_volume.value_changed.connect(_on_sfx_volume_changed)
	music_volume.value = Settings.music_volume
	music_volume.value_changed.connect(_on_music_volume_changed)


func _on_master_volume_changed(value: float) -> void:
	Settings.master_volume = value
	Settings.set_volume_for_bus("Master")


func _on_sfx_volume_changed(value: float) -> void:
	Settings.sfx_volume = value
	Settings.set_volume_for_bus("SFX")


func _on_music_volume_changed(value: float) -> void:
	Settings.music_volume = value
	Settings.set_volume_for_bus("Music")


func _on_leaving_tree() -> void:
	get_tree().paused = false
