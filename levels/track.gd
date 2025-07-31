@tool
extends CSGPolygon3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(_delta: float) -> void:
	for child in get_children():
		if child is CSGPolygon3D:
			child.mode = CSGPolygon3D.MODE_PATH
			child.path_node = self.path_node
	pass
