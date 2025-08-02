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

@onready var cast_center: = $cast_center
@onready var cast_ground_detector: = $cast_ground_detector
@onready var cast_front: = $cast_front
@onready var cast_rear: = $cast_rear
@onready var cast_left: = $cast_left
@onready var cast_right: = $cast_right

@onready var bumper_front_left: = $bumper_front_left
@onready var bumper_front_right: = $bumper_front_right

@export var camera_fov_base: float = 95
@export var camera_fov_max: float = 125

@export var air_gravity: float = 500

@export var ground_acceleration: float = 20
@export var ground_decceleration: float = 60

@export var ground_yaw_acceleration: float = 8
@export var ground_yaw_decceleration: float = 12
@export var ground_yaw_max_speed: float = 1.5

@export var ground_pitch_acceleration: float = 6
@export var ground_pitch_decceleration: float = 4
@export var ground_pitch_max_speed: float = 2

@export var ground_roll_acceleration: float = 6
@export var ground_roll_decceleration: float = 10
@export var ground_roll_max_speed: float = 2

@export var ground_friction: float = 1.5
@export var ground_max_speed: float = 100
@export var ground_max_speed_linear_increment: float = 2
@export var ground_max_speed_percent_increment: float = 1.0
@export var ground_gravity: float = 50
@export var ground_auto_pitch_speed: float = 8
@export var ground_auto_roll_speed: float = 8
@export var ground_suction_angle_offset: float = deg_to_rad(-2)
@export var ground_strafe_angle_offset: float = deg_to_rad(10)

@export var ground_bumper_bounce_speed: float = 1.5
@export var ground_bumper_friction: float = 100
@export var ground_bumper_min_speed: float = 10

@export var starting_speed: float = 80.0

var throttle: float  # current throttle input
var current_speed: float = starting_speed # tracks current acceleration in the direction the ship is looking
var rotate_input: Vector3  # tracks current input for rotation (pitch, roll, yaw)
var is_stalling: bool  # tracks whether ship is currently stalling
var grounded: bool  # tracks current grounded state (updated in func is_grounded())

var current_yaw_speed:float
var current_roll_speed:float
var current_pitch_speed:float


var current_lap_time: float = 0  # tracks current time, reset to 0 when reaching finish

# TODO: part of temp impl for mouse
var mouse_delta_x: float = 0.0

var _paused := false


func _ready() -> void:
	pause_ship()
	EventsBus.register_player(self)
	EventsBus.replay_controller_ready.connect(unpause_ship)

func pause_ship() -> void:
	_paused = true

func unpause_ship() -> void:
	_paused = false

func _physics_process(delta: float) -> void:
	if _paused:
		return
	# update lap timer
	current_lap_time += delta
	move_ship(delta)


func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta_x = event.relative.x


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

	var forward: = -basis.z
	var tilted_basis: = basis.rotated(basis.x, ground_suction_angle_offset)

	var horizon: = Vector3(forward.x, 0, forward.z).normalized()

	current_yaw_speed = update_rotation_speed(current_yaw_speed, rotate_input.y, ground_yaw_acceleration, ground_yaw_decceleration, ground_yaw_max_speed, delta)
	rotate(basis.y.normalized(), current_yaw_speed * delta)
	Debug.track("current_yaw_speed", current_yaw_speed)

	# current_roll_speed = update_rotation_speed(current_roll_speed, rotate_input.z, ground_roll_acceleration, ground_roll_decceleration, ground_roll_max_speed, delta)
	# HUD.debug("current_roll_speed", current_roll_speed)

	Debug.track("throttle", throttle)
	Debug.track("current_speed", current_speed)
	Debug.track("velocity.length", velocity.length())

	# TODO: check if this will work without the physics collision box
	# magnetically stick to surface until player pitches up or an extremely sharp drop-off

	# I want to get the front/back raycast distances to the nearest ground and adjust the velocity to keep
	# those as close as possible to a certain goal hover height

	# braking
	if throttle < 0 and current_speed > 0:
		current_speed += throttle * ground_decceleration * delta
	# accelerate
	else:
		current_speed += throttle * ground_acceleration * delta

	# cap speed to max speed
	if current_speed < -ground_max_speed:
		current_speed = -ground_max_speed
	elif current_speed > ground_max_speed:
		current_speed = ground_max_speed

	
	current_pitch_speed = update_rotation_speed(current_pitch_speed, rotate_input.x, ground_pitch_acceleration, ground_pitch_decceleration, ground_pitch_max_speed, delta)
	current_roll_speed = update_rotation_speed(current_roll_speed, rotate_input.z, ground_roll_acceleration, ground_roll_decceleration, ground_roll_max_speed, delta)

	# don't auto-adjust to surface if raycast is not colliding
	if ( cast_front.is_colliding() and cast_rear.is_colliding() and 
		 cast_left.is_colliding() and cast_right.is_colliding() ):

		# handle auto-pitch to surface and add current_pitch_speed from input
		var front_rear_diff: = raycast_distance(cast_front) - raycast_distance(cast_rear)
		Debug.track("front_rear_diff", front_rear_diff)
		rotate(basis.x.normalized(), -front_rear_diff * ground_auto_pitch_speed * delta + current_pitch_speed * delta)

		# handle auto-roll to surface
		var left_right_diff: = raycast_distance(cast_left) - raycast_distance(cast_right)
		Debug.track("left_right_diff", left_right_diff)
		rotate(basis.z.normalized(), left_right_diff * ground_auto_roll_speed * delta + current_roll_speed * delta)

		# add strafe movement by re-orienting the tilted basis based on input instead of roll angle
		if not is_zero_approx(rotate_input.z):
			tilted_basis = tilted_basis.rotated(tilted_basis.y, rotate_input.z * ground_strafe_angle_offset)
	
	# rotate if hitting wall
	if bumper_front_left.is_colliding():
		rotate(basis.y.normalized(), ground_bumper_bounce_speed * delta)
		if current_speed > ground_bumper_min_speed:
			current_speed -= ground_bumper_friction * delta
	if bumper_front_right.is_colliding():
		rotate(basis.y.normalized(), -ground_bumper_bounce_speed * delta)
		if current_speed > ground_bumper_min_speed:
			current_speed -= ground_bumper_friction * delta

	# apply gravity to current speed
	var angle_to_horizon: float
	angle_to_horizon = forward.angle_to(horizon)
	if forward.dot(Vector3.UP) < 0:
		angle_to_horizon = -angle_to_horizon
	Debug.track("angle_to_horizon", angle_to_horizon)
	current_speed += -angle_to_horizon * ground_gravity * delta

	if current_speed > 0:
		var tilted_forward: = -tilted_basis.z
		velocity = tilted_forward * current_speed
	else:
		velocity = forward * current_speed
	
	if not is_grounded():
		velocity += (air_gravity * delta) * -Vector3.UP

	# apply friction
	current_speed = move_toward(current_speed, 0, ground_friction * delta)
	
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
	# take keyboard yaw if pressed, otherwise, take mouse
	var yaw_input = Input.get_axis("yaw_right", "yaw_left")
	if yaw_input != 0:
		rotate_input.y = yaw_input
	else: # TODO: fix temp mouse control impl
		rotate_input.y = -mouse_delta_x / 10
		mouse_delta_x = 0
	rotate_input.x = Input.get_axis("pitch_down", "pitch_up")

	rotate_input.z = Input.get_axis("roll_right", "roll_left")
	
	throttle = Input.get_axis("brake", "gas")

	move_ship_grounded(delta)


func throttle_sound_adjust(in_throttle: float) -> void:
	# scaling formula:
	# OldRange = (OldMax - OldMin)  
	# NewRange = (NewMax - NewMin)  
	# NewValue = (((OldValue - OldMin) * NewRange) / OldRange) + NewMin
	# var sound_throttle: = clampf(in_throttle, 0, 1)
	var sound_throttle: = clampf(in_throttle, 0, 1)

	var pitch : float = (sound_throttle * 1.5) + 0.5
	engine_sound_a.pitch_scale = lerp(engine_sound_a.pitch_scale, pitch, 0.2)
	engine_sound_b.pitch_scale = lerp(engine_sound_b.pitch_scale, pitch, 0.2)


func adjust_camera_fov(speed: float) -> void:
	camera.fov = lerp(camera_fov_base, camera_fov_max, speed / ground_max_speed)
	# print(camera.fov)


func speed_sound_adjust(speed: float) -> void:
	speed = clampf(speed, 0, 150)
