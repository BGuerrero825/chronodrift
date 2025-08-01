extends Control

@onready var tracker_label := $DebugTracker
@onready var log_label := $DebugLog

func _ready() -> void:
    if OS.is_debug_build():
        tracker_label.visible = true
        log_label.visible = true
    else:
        tracker_label.visible = false
        log_label.visible = false

func _process(_delta: float) -> void:
    if OS.is_debug_build():
        tracker_label.text = Debug.track_str
        log_label.text = Debug.log_str
