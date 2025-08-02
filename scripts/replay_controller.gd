class_name ReplayController
extends Node3D

enum State {REPLAYING, PAUSED}
var _current_state := State.PAUSED
var _previous_state := State.PAUSED

var _is_recording := true
var replay_data_array: Array[ReplayData] = []
var current_recording_data: ReplayData = null
var current_replay_id := 1

var start_position := Vector3.ZERO
var start_transform := Transform3D.IDENTITY
var player_ref: PlayerShip = null
var replay_ships: Array[ReplayShip] = []

const replay_tick_rate := 0.008
@export var replay_offset_time_seconds = 0.1
var _replay_offset_time := int(0.05 / replay_tick_rate)
var tick_accumulator := 0.0

const start_delay := 2.0

@onready var replay_ship_scene := preload("res://scenes/replay_ship.tscn")

func _ready() -> void:
	player_ref = EventsBus.get_player_ref()
	assert(player_ref != null, "player ref not available when replay controller starts")

	start_position = player_ref.global_position
	start_transform = player_ref.global_transform
	Debug.log("starting position: " + str(start_position))
	
	EventsBus.player_reached_goal.connect(player_reached_goal)

	await get_tree().create_timer(start_delay).timeout

	EventsBus.emit_replay_controller_ready()
	_start_new_recording()


func player_reached_goal() -> void:
	Debug.log("replay controller sees player reached goal")
	_finish_current_recording()
	_reset_player_increase_speed()
	_start_new_recording()
	_start_replaying_all()

func _process(_delta: float) -> void: 
	if OS.is_debug_build():
		debug_input()

func _physics_process(delta: float) -> void:
	tick_accumulator += delta
	
	if tick_accumulator >= replay_tick_rate:
		tick_accumulator = 0.0
		process_tick()

func process_tick() -> void:
	if _is_recording and current_recording_data:
		current_recording_data.record_frame(player_ref)

	process_state(_current_state)

func _start_new_recording() -> void:
	Debug.log("starting new recording for replay " + str(current_replay_id))
	current_recording_data = ReplayData.new()
	current_recording_data.replay_id = current_replay_id
	_is_recording = true

func _finish_current_recording() -> void:
	if current_recording_data:
		Debug.log("finishing recording for replay " + str(current_recording_data.replay_id))
		replay_data_array.append(current_recording_data)

		var tmp_replay_ship := replay_ship_scene.instantiate()
		tmp_replay_ship.replay_data = current_recording_data
		add_child(tmp_replay_ship)
		tmp_replay_ship.global_position = start_position
		replay_ships.append(tmp_replay_ship)

		current_recording_data = null
		current_replay_id += 1

	_is_recording = false

func _reset_player_increase_speed() -> void:
	player_ref.global_position = start_position
	player_ref.global_transform = start_transform
	player_ref.velocity = Vector3.ZERO
	player_ref.current_speed = player_ref.starting_speed

	player_ref.ground_max_speed += player_ref.ground_max_speed_linear_increment
	player_ref.ground_max_speed *= player_ref.ground_max_speed_percent_increment

func _start_replaying_all() -> void:
	var current_tick_offset := _replay_offset_time * len(replay_ships)
	for s in replay_ships:
		s.tick_offset = current_tick_offset
		s.play()
		current_tick_offset -= _replay_offset_time
	change_state(State.REPLAYING)

func change_state(new_state: State) -> void:
	if new_state == _current_state:
		return
	exit_state(_current_state)
	_previous_state = _current_state
	_current_state = new_state
	enter_state(_current_state)

func process_state(current_state: State) -> void:
	match current_state:
		State.REPLAYING:
			Debug.track("replay_state", "REPLAYING")
			Debug.track("recording_state", "RECORDING" if _is_recording else "NOT_RECORDING")
			for ship in replay_ships:
				ship.increment_tick()
		State.PAUSED:
			Debug.track("replay_state", "PAUSED")
			Debug.track("recording_state", "RECORDING" if _is_recording else "NOT_RECORDING")
		_:
			assert(false, "processing unknown state")

func enter_state(state: State) -> void:
	match state:
		State.REPLAYING:
			Debug.log("entering REPLAYING state")
			for replay in replay_ships:
				if is_instance_valid(replay):
					replay.play()
		State.PAUSED:
			Debug.log("entering PAUSED state")
		_:
			assert(false, "entering unknown state")

func exit_state(state: State) -> void:
	match state:
		State.REPLAYING:
			Debug.log("exiting REPLAYING state")
		State.PAUSED:
			Debug.log("exiting PAUSED state")
		_:
			assert(false, "exiting unknown state")

func debug_input() -> void:
	if Input.is_action_just_released("debug1"):
		_is_recording = not _is_recording
		Debug.log("Recording: " + str(_is_recording))
	
	if Input.is_action_just_released("debug2"):
		change_state(State.REPLAYING)
	
	if Input.is_action_just_released("debug3"):
		change_state(State.PAUSED)

	if Input.is_action_just_released("debug4"):
		_finish_current_recording()
		_reset_player_increase_speed()
		_start_replaying_all()
		_start_new_recording()
