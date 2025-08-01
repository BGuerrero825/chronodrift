class_name Main
extends Node3D

@export var main_menu_scene: PackedScene
@export var settings_menu_scene: PackedScene
@export var level_1_scene: PackedScene
@export var level_2_scene: PackedScene
@export var level_3_scene: PackedScene

@onready var ui: CanvasLayer = %UILayer
@onready var settings_button: Button = %SettingsButton


func _ready() -> void:
	settings_button.pressed.connect(_on_settings_button_pressed)
	go_main_menu()


func go_main_menu() -> void:
	var main_menu: MainMenu = main_menu_scene.instantiate()
	ui.add_child(main_menu)
	main_menu.position = Vector2.ZERO
	main_menu.play_1.pressed.connect(go_level.bind(level_1_scene))
	main_menu.play_2.pressed.connect(go_level.bind(level_2_scene))
	main_menu.play_3.pressed.connect(go_level.bind(level_3_scene))


func go_level(level_scene: PackedScene) -> void:
	var level: Node3D = level_scene.instantiate()
	add_child(level)
	level.position = Vector3.ZERO


func _on_settings_button_pressed() -> void:
	var settings: SettingsMenu = settings_menu_scene.instantiate()
	ui.add_child(settings)
	settings.position = Vector2.ZERO
	settings.exit_button.pressed.connect(settings.queue_free)
