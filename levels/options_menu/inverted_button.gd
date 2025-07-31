extends Button

@onready var label : Label = %Label

func _on_pressed() -> void:
	Options.inverted = !Options.inverted
	label.text = "Inverted Y: " + str(Options.inverted)
