class_name ReplayShip
extends Area3D

@export var _paused := true
@export var replay_data : ReplayData = null
var current_tick := 0
var tick_offset := 0

@onready var thruster_particles: Node3D = %ThrusterParticles
@onready var ship_model: Node3D = %ship_model

func _ready() -> void:
	ship_model.get_child(2).play("shake_ship")

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
		EventsBus.emit_replay_ship_reached_goal()
		return
	
	global_position = replay_data.position_tracker[current_tick]
	global_transform = replay_data.transform_tracker[current_tick]

	thruster_particles.throttle_updated(replay_data.throttle_tracker[current_tick])

	current_tick += 1
