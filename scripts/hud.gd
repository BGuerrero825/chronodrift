extends Control

@onready var tracker_label := $DebugTracker
@onready var log_label := $DebugLog

@onready var lap_time := %LapTime
@onready var target_time := %TargetTime
@onready var start_timer := %StartTime
var start_timer_tracker := 0.0

var replay_controller_ref: ReplayController = null

func _ready() -> void:
	if OS.is_debug_build():
		tracker_label.visible = true
		log_label.visible = true
	else:
		tracker_label.visible = false
		log_label.visible = false
	
	EventsBus.start_delay_triggered.connect(_show_start_timer)

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
	
	if not replay_controller_ref.start_delay_active:
		lap_time.text = "%5.2f" % replay_controller_ref.current_lap_time
	else:
		lap_time.text = "0.00"
	target_time.text = "TARGET: %5.2f" % replay_controller_ref.target_lap_time
