class_name ShaderCompiler
extends Node3D

signal done


func _ready() -> void:
	await get_tree().create_timer(2).timeout
	done.emit()
