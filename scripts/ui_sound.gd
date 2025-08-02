extends Node

var button_press_sounds: Array[AudioStreamPlayer] = []
var button_hover_sounds: Array[AudioStreamPlayer] = []

@onready var press_1: AudioStreamPlayer = $ButtonPress
@onready var press_2: AudioStreamPlayer = $ButtonPress2
@onready var press_3: AudioStreamPlayer = $ButtonPress3
@onready var hover_1: AudioStreamPlayer = $ButtonHover
@onready var hover_2: AudioStreamPlayer = $ButtonHover2
@onready var hover_3: AudioStreamPlayer = $ButtonHover3


func _ready() -> void:
	# when _ready is called, there might already be nodes in the tree, so connect all existing buttons
	connect_nodes(get_tree().root)
	get_tree().node_added.connect(_on_tree_node_added)

	button_press_sounds = [press_1, press_2, press_3]
	button_hover_sounds = [hover_1, hover_2, hover_3]


func _on_tree_node_added(node: Node) -> void:
	if node is BaseButton:
		connect_to_button(node)


# Recursively connect all buttons. This runs only from _ready()
func connect_nodes(root: Node) -> void:
	for child in root.get_children():
		if child is BaseButton:
			connect_to_button(child)
		connect_nodes(child)


func connect_to_button(button: BaseButton) -> void:
	if button.pressed.is_connected(_on_button_pressed):
		return
	button.pressed.connect(_on_button_pressed)
	button.mouse_entered.connect(_on_button_mouse_entered)
	button.focus_entered.connect(_on_button_mouse_entered)


func _on_button_pressed() -> void:
	button_press_sounds.pick_random().play()


func _on_button_mouse_entered() -> void:
	button_hover_sounds.pick_random().play()
