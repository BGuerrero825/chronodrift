class_name ReplayShip
extends Area3D

@export var _paused := true
@export var replay_data : ReplayData = null
var current_tick := 0
var tick_offset := 0

func play() -> void:
	_paused = false
	current_tick = tick_offset

func pause() -> void:
	_paused = true

func increment_tick() -> void:
	Debug.track("replay_ship_pos", self.position)
	if _paused:
		return
	
	assert(replay_data != null, "attempting to replay a replay ship without replay data")
	
	if current_tick >= len(replay_data.position_tracker):
		_paused = true
		return
	
	global_position = replay_data.position_tracker[current_tick]
	global_transform = replay_data.transform_tracker[current_tick]

	current_tick += 1
