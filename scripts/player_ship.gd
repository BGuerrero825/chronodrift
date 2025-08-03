class_name PlayerShip
extends CharacterBody3D

# Draft Controls
# Throttle/Brake: Triggers or W and S
# Yaw: Left Joystick or A and D 
# Roll: Right Joystick or left and right arrow
# Pitch: Right Joystick or up and down down arrow

@onready var camera: = $Camera3D

@onready var engine_sound_a: AudioStreamPlayer3D = %EngineHum
@onready var engine_sound_b: AudioStreamPlayer3D = %EngineBuzz
@onready var collision_sound: AudioStreamPlayer3D = %CollisionSound
@onready var airbrake_engage_sound: AudioStreamPlayer3D = %AirBrakeEngage
@onready var airbrake_hold_sound: AudioStreamPlayer3D = %AirBrakeHold
@onready var rocket_drone: AudioStreamPlayer3D = %RocketDrone
@onready var rocket_drone_orig_vol: float = %RocketDrone.volume_db

@onready var cast_center: = $cast_center
@onready var cast_ground_detector: = $cast_ground_detector
@onready var cast_front: = $cast_front
@onready var cast_rear: = $cast_rear
@onready var cast_left: = $cast_left
@onready var cast_right: = $cast_right

@onready var bumper_front_left: = $bumper_front_left
@onready var bumper_front_right: = $bumper_front_right

@onready var thruster_particles: Node3D = %ThrusterParticles
@onready var scraping_particles: GPUParticles3D = %ScrapingParticles
@onready var explosion_particles: SkyExplosion = %SkyExplosion
@onready var ship_model := %ship_model

@export var camera_fov_base: float = 95
@export var camera_fov_max: float = 125

@export var friction: float = 15
@export var acceleration: float = 25
@export var brake_deceleration: float = 50

@export var yaw_acceleration: float = 8
@export var yaw_decceleration: float = 12
@export var yaw_max_speed: float = 1.5

@export var yaw_drift_acceleration: float = 35
@export var yaw_drift_decceleration: float = 1
@export var yaw_drift_max_speed: float = 6

@export var pitch_acceleration: float = 6
@export var pitch_decceleration: float = 4
@export var pitch_max_speed: float = 2

@export var roll_acceleration: float = 6
@export var roll_decceleration: float = 10
@export var roll_max_speed: float = 2

@export var gravity : float = 20
@export var max_speed: float = 85
@export var aero_max_speed_mod: float = 1.1
@export var max_speed_linear_increment: float = 2
@export var max_speed_percent_increment: float = 1.0
@export var auto_pitch_speed: float = 8
@export var auto_roll_speed: float = 8
@export var suction_angle_offset: float = deg_to_rad(-2)
@export var strafe_angle_offset: float = deg_to_rad(10)

@export var track_magnetism: float = 40.
@export var track_magnetism_scaling: float = 2.2
@export var track_cushion: float = 50

@export var bumper_bounce_speed: float = 4.5
@export var bumper_friction: float = 150
@export var bumper_min_speed: float = 10

@export var starting_speed: float = 80.0

var throttle: float  # current throttle input
var brake: float  # current brake input
var current_speed: float = starting_speed # tracks current acceleration in the direction the ship is looking
var rotate_input: Vector3  # tracks current input for rotation (pitch, roll, yaw)
var is_stalling: bool  # tracks whether ship is currently stalling
var grounded: bool  # tracks current grounded state (updated in func is_grounded())
var drifting: bool = false

var current_yaw_speed:float
var current_roll_speed:float
var current_pitch_speed:float


var current_lap_time: float = 0  # tracks current time, reset to 0 when reaching finish

var _paused := false
var invulnerable := true


func _ready() -> void:
	pause_ship()
	EventsBus.register_player(self)
	EventsBus.replay_controller_ready.connect(unpause_ship)
	ship_model.get_child(2).play("shake_ship")


func pause_ship() -> void:
	_paused = true
	engine_sound_a.stop()
	engine_sound_b.stop()

func unpause_ship() -> void:
	_paused = false
	engine_sound_a.play()
	engine_sound_b.play()

func _physics_process(delta: float) -> void:
	if _paused:
		return
	# update lap timer

	if OS.is_debug_build():
		_debug_controls()

	current_lap_time += delta
	move_ship(delta)

func _debug_controls() -> void:
	if Input.is_action_just_released("debug4"):
		destroy_ship()

func destroy_ship() -> void:
	ship_model.visible = false
	explosion_particles.explode()
	EventsBus.emit_player_destroyed()
	pause_ship()

func respawn_ship()  -> void:
	ship_model.visible = true
	invulnerable = true
	unpause_ship()

# returns raycast distance to collider, this should not be called if raycast is not colliding
func raycast_distance(raycast: RayCast3D) -> float:
	assert(raycast.is_colliding(), "getting raycast distance when there is no collision")
	return global_transform.origin.distance_to(raycast.get_collision_point())


# returns a new current rotation speed
func update_rotation_speed(current_rotation_speed: float, 
							current_input: float,
							rotation_acceleration: float,
							rotation_decceleration: float,
							max_rotation_speed: float,
							delta: float) -> float:

	if not is_zero_approx(current_input):
		if sign(current_rotation_speed) != current_input:
			current_rotation_speed += current_input * rotation_decceleration * delta
		current_rotation_speed += current_input * rotation_acceleration * delta
		current_rotation_speed = clampf(current_rotation_speed, -max_rotation_speed, max_rotation_speed)
	else:
		current_rotation_speed = move_toward(current_rotation_speed, 0, rotation_decceleration * delta)

	return current_rotation_speed


func move_ship_grounded(delta: float) -> void:

	throttle_sound_adjust(throttle)
	brake_sound_adjust(brake)
	thruster_particles.throttle_updated(throttle)

	var forward: = -basis.z
	var tilted_basis: = basis.rotated(basis.x, suction_angle_offset)

	var horizon: = Vector3(forward.x, 0, forward.z).normalized()

	current_yaw_speed = update_rotation_speed(current_yaw_speed, rotate_input.y, yaw_acceleration, yaw_decceleration, yaw_max_speed, delta)
	if drifting:
		current_yaw_speed = update_rotation_speed(current_yaw_speed, rotate_input.y, yaw_drift_acceleration, yaw_drift_decceleration, yaw_drift_max_speed, delta)
	else:
		current_yaw_speed = update_rotation_speed(current_yaw_speed, rotate_input.y, yaw_acceleration, yaw_decceleration, yaw_max_speed, delta)

	rotate(basis.y.normalized(), current_yaw_speed * delta)
	Debug.track("current_yaw_speed", current_yaw_speed)

	Debug.track("throttle", throttle)
	Debug.track("brake", brake)
	Debug.track("current_speed", current_speed)
	Debug.track("velocity.length", velocity.length())

	drifting = false
	# braking 
	if brake > 0.05 and current_speed > 1:
		current_speed += brake * -brake_deceleration * delta
		drifting = true
	# deccel / friction
	elif throttle < 0.05:
		current_speed = move_toward(current_speed, 0, friction * delta)

	if throttle >= 0.05:
		current_speed += throttle * acceleration * delta

	# cap speed to max speed
	var curr_max = max_speed
	if rotate_input.x < -.8:
		curr_max = aero_max_speed_mod * max_speed
	if current_speed < -curr_max:
		current_speed = move_toward(current_speed, -curr_max, delta * brake_deceleration)
	elif current_speed > curr_max:
		current_speed = move_toward(current_speed, curr_max, delta * brake_deceleration)

	
	current_pitch_speed = update_rotation_speed(current_pitch_speed, rotate_input.x, pitch_acceleration, pitch_decceleration, pitch_max_speed, delta)
	current_roll_speed = update_rotation_speed(current_roll_speed, rotate_input.z, roll_acceleration, roll_decceleration, roll_max_speed, delta)

	# don't auto-adjust to surface if raycast is not colliding
	if ( cast_front.is_colliding() and cast_rear.is_colliding() and 
		 cast_left.is_colliding() and cast_right.is_colliding() ):

		# handle auto-pitch to surface and add current_pitch_speed from input
		var front_rear_diff: = raycast_distance(cast_front) - raycast_distance(cast_rear)
		Debug.track("front_rear_diff", front_rear_diff)
		rotate(basis.x.normalized(), -front_rear_diff * auto_pitch_speed * delta + current_pitch_speed * delta)

		# handle auto-roll to surface
		var left_right_diff: = raycast_distance(cast_left) - raycast_distance(cast_right)
		Debug.track("left_right_diff", left_right_diff)
		rotate(basis.z.normalized(), left_right_diff * auto_roll_speed * delta + current_roll_speed * delta)

		# add strafe movement by re-orienting the tilted basis based on input instead of roll angle
		if not is_zero_approx(rotate_input.z):
			tilted_basis = tilted_basis.rotated(tilted_basis.y, rotate_input.z * strafe_angle_offset)
	
	# rotate if hitting wall
	if bumper_front_left.is_colliding():
		rotate(basis.y.normalized(), bumper_bounce_speed * delta)
		if current_speed > bumper_min_speed:
			current_speed -= bumper_friction * delta
		scraping_particles.position = bumper_front_left.position
		scraping_particles.emitting = true
		collision_sound.collide(bumper_front_left.position)
	elif bumper_front_right.is_colliding():
		rotate(basis.y.normalized(), -bumper_bounce_speed * delta)
		if current_speed > bumper_min_speed:
			current_speed -= bumper_friction * delta
		scraping_particles.position = bumper_front_right.position
		scraping_particles.emitting = true
		collision_sound.collide(bumper_front_right.position)
	else:
		collision_sound.stop_colliding()
		scraping_particles.emitting = false

	# apply gravity to current speed
	var angle_to_horizon: float
	angle_to_horizon = forward.angle_to(horizon)
	if forward.dot(Vector3.UP) < 0:
		angle_to_horizon = -angle_to_horizon
	Debug.track("angle_to_horizon", angle_to_horizon)
	current_speed += -angle_to_horizon * gravity * delta

	if current_speed > 0:
		var tilted_forward: = -tilted_basis.z
		velocity = tilted_forward * current_speed
	else:
		velocity = forward * current_speed
	
	# apply track magnetism
	var track_normal = Vector3.UP
	var track_distance = 10.
	if cast_ground_detector.is_colliding():
		track_distance = raycast_distance(cast_ground_detector)
		track_normal = cast_ground_detector.get_collision_normal()
		Debug.track("distance to ground", raycast_distance(cast_ground_detector))
	velocity += track_magnetism * delta * pow(track_distance, track_magnetism_scaling) * -track_normal


	speed_sound_adjust(current_speed)
	adjust_camera_fov(current_speed)

	move_and_slide()


func is_grounded() -> bool:
	var new_grounded:bool = cast_ground_detector.is_colliding()

	# transitioning from grounded to not grounded
	if grounded and not new_grounded:
		current_pitch_speed = 0

	grounded = new_grounded

	if grounded: is_stalling = false  # always disable stalling when grounded
	Debug.track("grounded", grounded)
	return grounded
	# return true
	# return false


func move_ship(delta: float) -> void:
	rotate_input.y = Input.get_axis("yaw_right", "yaw_left")
	rotate_input.x = Input.get_axis("pitch_down", "pitch_up")
	rotate_input.z = Input.get_axis("roll_right", "roll_left")
	
	throttle = Input.get_action_strength("gas")
	brake = Input.get_action_strength("brake")

	move_ship_grounded(delta)


func throttle_sound_adjust(in_throttle: float) -> void:
	var sound_throttle: = clampf(in_throttle, 0, 1)

	var pitch : float = (sound_throttle * 1.5) + 0.5
	engine_sound_a.pitch_scale = lerp(engine_sound_a.pitch_scale, pitch, 0.2)
	engine_sound_b.pitch_scale = lerp(engine_sound_b.pitch_scale, pitch, 0.2)

	rocket_drone.volume_db = rocket_drone_orig_vol + (current_speed / max_speed) * 5
	rocket_drone.pitch_scale = 0.5 + (current_speed / max_speed) * 1.5


func brake_sound_adjust(_in_brake: float) -> void:
	if Input.is_action_just_pressed("brake"):
		airbrake_engage_sound.play()
	if brake > 0.1:
		if not airbrake_hold_sound.playing:
			airbrake_hold_sound.play()
	else:
		airbrake_hold_sound.stop()

	
func adjust_camera_fov(speed: float) -> void:
	camera.fov = lerp(camera_fov_base, camera_fov_max, speed / max_speed)


func speed_sound_adjust(speed: float) -> void:
	speed = clampf(speed, 0, 150)


func _on_area_3d_area_entered(area:Area3D) -> void:
	if area is ReplayShip and not invulnerable: destroy_ship()
	if area is SafeGate: invulnerable = true
	if area is DangerGate: invulnerable = false
