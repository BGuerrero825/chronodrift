class_name SafeGate
extends Area3D

func _ready() -> void:
    if not OS.is_debug_build():
        %DebugIndicator.visible = false