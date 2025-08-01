class_name ReplayController
extends Node3D

enum State {RECORDING, REPLAYING, PAUSED, STOP_AND_SAVE}
var _current_state := State.PAUSED
var _previous_state := State.PAUSED

var replay_data_array: Array[ReplayData] = []
var current_replay_data: ReplayData = null
var current_replay_id := 1

var start_position := Vector3.ZERO

var player_ref: PlayerShip = null

var current_replay_ship: ReplayShip = null

@onready var replay_ship_scene := preload("res://scenes/replay_ship.tscn")

func _ready() -> void:
	player_ref = EventsBus.get_player_ref()
	assert(player_ref != null, "player ref not available when replay controller starts")
	start_position = player_ref.global_position
	Debug.log("starting position: " + str(start_position))
	var tmp_replay_ship := replay_ship_scene.instantiate()
	add_child(tmp_replay_ship)
	tmp_replay_ship.global_position = start_position
	current_replay_ship = tmp_replay_ship

func _process(_delta: float) -> void: 
	if OS.is_debug_build():
		debug_input()

	# transition in enter/exit states, use change_state
	process_state(_current_state)

func change_state(new_state: State) -> void:
	if new_state == _current_state:
		return
	exit_state(_current_state)
	_previous_state = _current_state
	_current_state = new_state
	enter_state(_current_state)

func process_state(current_state: State) -> void:
	# TODO: might want to keep track of delta here as well, or use a fixed tick rate
	match current_state:
		State.RECORDING:
			Debug.track("replay_state", "RECORDING")
			current_replay_data.record_frame(player_ref)
		State.REPLAYING:
			Debug.track("replay_state", "REPLAYING")
		State.PAUSED:
			Debug.track("replay_state", "PAUSED")
		State.STOP_AND_SAVE:
			Debug.track("replay_state", "STOP_AND_SAVE")
			current_replay_ship.replay_data = current_replay_data
		_:
			assert(false, "processing unknown state")

func enter_state(state: State) -> void:
	match state:
		State.RECORDING:
			Debug.log("entering RECORDING state")
			current_replay_data = ReplayData.new()
			current_replay_data.replay_id = current_replay_id
			current_replay_id += 1
			Debug.log("current_replay_data: " + str(current_replay_data.replay_id))
		State.REPLAYING:
			Debug.log("entering REPLAYING state")
			current_replay_ship.play()
		State.PAUSED:
			Debug.log("entering PAUSED state")
		State.STOP_AND_SAVE:
			Debug.log("entering STOP_AND_SAVE state")
			current_replay_ship.replay_data = current_replay_data
		_:
			assert(false, "entering unknown state")

func exit_state(state: State) -> void:
	match state:
		State.RECORDING:
			Debug.log("exiting RECORDING state")
		State.REPLAYING:
			Debug.log("exiting REPLAYING state")
		State.PAUSED:
			Debug.log("exiting PAUSED state")
		State.STOP_AND_SAVE:
			Debug.log("exiting STOP_AND_SAVE state")
		_:
			assert(false, "exiting unknown state")

func debug_input() -> void:
	if Input.is_action_just_released("debug1"):
		change_state(State.RECORDING)
	if Input.is_action_just_released("debug2"):
		change_state(State.REPLAYING)
	if Input.is_action_just_released("debug3"):
		change_state(State.PAUSED)

	if Input.is_action_just_released("debug4"):
		change_state(State.STOP_AND_SAVE)
