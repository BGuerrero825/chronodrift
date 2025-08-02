class_name SettingsMenu
extends Control

@onready var exit_button: Button = %ExitButton
@onready var master_volume: HSlider = %MasterVolumeSlider
@onready var sfx_volume: HSlider = %SFXVolumeSlider
@onready var music_volume: HSlider = %MusicVolumeSlider
@onready var slider_click: AudioStreamPlayer = %SliderClick


func _ready() -> void:
	get_tree().paused = true
	tree_exiting.connect(_on_leaving_tree)

	master_volume.grab_focus()
	master_volume.value = Settings.master_volume
	master_volume.value_changed.connect(_on_master_volume_changed)
	master_volume.focus_entered.connect(UISound._on_button_mouse_entered)

	sfx_volume.value = Settings.sfx_volume
	sfx_volume.value_changed.connect(_on_sfx_volume_changed)
	sfx_volume.focus_entered.connect(UISound._on_button_mouse_entered)

	music_volume.value = Settings.music_volume
	music_volume.value_changed.connect(_on_music_volume_changed)
	music_volume.focus_entered.connect(UISound._on_button_mouse_entered)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		queue_free()


func _on_master_volume_changed(value: float) -> void:
	Settings.master_volume = value
	Settings.set_volume_for_bus("Master")
	slider_click.play()


func _on_sfx_volume_changed(value: float) -> void:
	Settings.sfx_volume = value
	Settings.set_volume_for_bus("SFX")
	slider_click.play()


func _on_music_volume_changed(value: float) -> void:
	Settings.music_volume = value
	Settings.set_volume_for_bus("Music")
	slider_click.play()


func _on_leaving_tree() -> void:
	get_tree().paused = false
