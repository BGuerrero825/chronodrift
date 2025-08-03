extends Control

@onready var tracker_label := $DebugTracker
@onready var log_label := $DebugLog

@onready var lap_time := %LapTime
@onready var target_time := %TargetTime
@onready var start_timer := %StartTime
@onready var victory_label := %Victory
var start_timer_tracker := 0.0

var replay_controller_ref: ReplayController = null

var victory_time := -1.0

func _ready() -> void:
    if OS.is_debug_build():
        tracker_label.visible = true
        log_label.visible = true
    else:
        tracker_label.visible = false
        log_label.visible = false
    
    EventsBus.start_delay_triggered.connect(_show_start_timer)
    EventsBus.player_beat_target_time.connect(_show_victory)
    EventsBus.player_triggered_level_reset.connect(_hide_victory)
    EventsBus.player_triggered_lap_reset.connect(_hide_victory)

func _show_victory() -> void:
    victory_label.visible = true
    victory_time = replay_controller_ref.current_lap_time

func _hide_victory() -> void:
    victory_label.visible = false
    victory_time = -1.0

func _show_start_timer(seconds) -> void:
    start_timer_tracker = seconds
    start_timer.visible = true
    await get_tree().create_timer(seconds).timeout
    start_timer.visible = false

func _physics_process(delta: float) -> void:
    start_timer_tracker -= delta
    start_timer.text = "%.0f" % start_timer_tracker

func _process(_delta: float) -> void:
    if OS.is_debug_build():
        tracker_label.text = Debug.track_str
        log_label.text = Debug.log_str 

    if not replay_controller_ref:
        replay_controller_ref = EventsBus.get_replay_controller_ref()
        return
    
    target_time.text = "TARGET: %5.2f" % replay_controller_ref.target_lap_time

    if victory_time > 0:
        lap_time.text = "%5.2f" % victory_time
        return
    
    if not replay_controller_ref.start_delay_active:
        lap_time.text = "%5.2f" % replay_controller_ref.current_lap_time
    else:
        lap_time.text = "0.00"
    
