class_name Main
extends Node3D

@export var main_menu_scene: PackedScene
@export var settings_menu_scene: PackedScene
@export var level_1_scene: PackedScene
@export var level_2_scene: PackedScene
@export var level_3_scene: PackedScene
var main_menu: MainMenu
var settings_menu: SettingsMenu

@onready var ui: CanvasLayer = %UILayer


func _ready() -> void:
	# MusicManager.play_menu_music()
	MusicManager.play_gameplay_music()

	go_main_menu()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if not is_instance_valid(settings_menu):
			_on_settings_button_pressed()


func go_main_menu() -> void:
	main_menu = main_menu_scene.instantiate()
	ui.add_child(main_menu)
	main_menu.position = Vector2.ZERO
	main_menu.play_1.pressed.connect(go_level.bind(level_1_scene))
	main_menu.play_2.pressed.connect(go_level.bind(level_2_scene))
	main_menu.play_3.pressed.connect(go_level.bind(level_3_scene))
	main_menu.settings_button.pressed.connect(_on_settings_button_pressed)


func go_level(level_scene: PackedScene) -> void:
	MusicManager.play_gameplay_music()
	
	var level: Node3D = level_scene.instantiate()
	add_child(level)
	level.position = Vector3.ZERO

func _on_settings_button_pressed() -> void:
	settings_menu = settings_menu_scene.instantiate()
	ui.add_child(settings_menu)
	settings_menu.position = Vector2.ZERO
	settings_menu.exit_button.pressed.connect(settings_menu.queue_free)
	settings_menu.reset_lap_button.pressed.connect(EventsBus.emit_player_triggered_lap_reset)
	settings_menu.reset_level_button.pressed.connect(EventsBus.emit_player_triggered_level_reset)

	# If the main menu is up, we aren't in the game. So the main menu should
	# grab the focus of the controller
	if is_instance_valid(main_menu):
		settings_menu.tree_exiting.connect(func()->void:main_menu.play_1.grab_focus())
