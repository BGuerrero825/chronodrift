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
var start_max_speed := 0.0
var player_ref: PlayerShip = null
var replay_ships: Array[ReplayShip] = []

const replay_tick_rate := 0.008
@export var replay_offset_time_seconds = 0.2
var _replay_offset_time := int(0.05 / replay_tick_rate)
var tick_accumulator := 0.0

var current_lap_time := 0.0
@export var target_lap_time := 28.0

const start_delay := 2.0
const init_start_delay := 5.0
const replay_won_delay := 2.5

var start_delay_active := false

@onready var replay_ship_scene := preload("res://scenes/replay_ship.tscn")

func _ready() -> void:
    EventsBus.register_replay_controller(self)
    player_ref = EventsBus.get_player_ref()
    assert(player_ref != null, "player ref not available when replay controller starts")

    start_position = player_ref.global_position
    start_transform = player_ref.global_transform
    start_max_speed = player_ref.max_speed
    Debug.log("starting position: " + str(start_position))
    
    EventsBus.player_reached_goal.connect(player_reached_goal)
    EventsBus.player_triggered_lap_reset.connect(_respawn_player)
    EventsBus.player_triggered_level_reset.connect(_reset_level)
    EventsBus.replay_ship_reached_goal.connect(_replay_ship_won)
    EventsBus.player_destroyed.connect(_player_is_destroyed)

    await delay_start(init_start_delay)

    EventsBus.emit_replay_controller_ready()
    _start_new_recording()

func _player_is_destroyed() -> void:
    _pause_all_replays()
    await get_tree().create_timer(replay_won_delay).timeout
    _respawn_player()

func _replay_ship_won() -> void:
    player_ref.pause_ship()
    await get_tree().create_timer(replay_won_delay).timeout
    _respawn_player()

func _reset_level() -> void:
    for s in replay_ships:
        if is_instance_valid(s):
            s.queue_free()
    replay_ships = []
    player_ref.max_speed = start_max_speed
    _respawn_player()

func delay_start(seconds: float) -> void:
    EventsBus.emit_start_delay_triggered(seconds)
    start_delay_active = true
    await get_tree().create_timer(seconds).timeout
    start_delay_active = false

func player_reached_goal() -> void:
    Debug.log("replay controller sees player reached goal")
    if current_lap_time <= target_lap_time:
        EventsBus.emit_player_beat_target_time()
        return
    _finish_current_recording()
    _pause_all_replays()
    _increase_player_speed()
    _reset_player()
    _start_new_recording()
    _start_replaying_all()

func _pause_all_replays() -> void:
    for s in replay_ships:
        s.pause()

func _physics_process(delta: float) -> void:
    if OS.is_debug_build():
        debug_input()

    tick_accumulator += delta
    current_lap_time += delta
    
    if tick_accumulator >= replay_tick_rate:
        tick_accumulator = 0.0
        process_tick()

func process_tick() -> void:
    if _is_recording and current_recording_data:
        current_recording_data.record_frame(player_ref)

    process_state(_current_state)

func _start_new_recording() -> void:
    current_lap_time = 0
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

func _reset_player() -> void:
    player_ref.global_position = start_position
    player_ref.global_transform = start_transform
    player_ref.velocity = Vector3.ZERO
    player_ref.current_speed = player_ref.starting_speed
    player_ref.ship_model.visible = true

func _increase_player_speed() -> void:
    player_ref.max_speed += player_ref.max_speed_linear_increment
    player_ref.max_speed *= player_ref.max_speed_percent_increment

func _start_replaying_all() -> void:
    var current_tick_offset := _replay_offset_time * len(replay_ships)
    for s in replay_ships:
        # if is_instance_valid(s):
        s.tick_offset = current_tick_offset
        s.play()
        current_tick_offset -= _replay_offset_time
    change_state(State.REPLAYING)

func _cancel_current_recording() -> void:
    _is_recording = false

func _respawn_player() -> void:
    _cancel_current_recording()
    _reset_player()
    player_ref.pause_ship()

    await delay_start(start_delay)

    _start_new_recording()
    player_ref.respawn_ship()
    _start_replaying_all()

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
                if is_instance_valid(ship):
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
                # if is_instance_valid(replay):
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
    pass
    if Input.is_action_just_released("debug5"):
        Debug.log("RESPAWNING PLAYER")
        _respawn_player()
# 	if Input.is_action_just_released("debug1"):
# 		_is_recording = not _is_recording
# 		Debug.log("Recording: " + str(_is_recording))
    
# 	if Input.is_action_just_released("debug2"):
# 		change_state(State.REPLAYING)
    
# 	if Input.is_action_just_released("debug3"):
# 		change_state(State.PAUSED)

# 	if Input.is_action_just_released("debug4"):
# 		_finish_current_recording()
# 		_reset_player_increase_speed()
# 		_start_replaying_all()
# 		_start_new_recording()
