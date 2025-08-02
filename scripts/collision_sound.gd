extends AudioStreamPlayer3D

@export var offset_forward: float


func collide(collision_position: Vector3) -> void:
	position = collision_position + Vector3(0, 0, -offset_forward)
	if playing:
		return
	play()


func stop_colliding() -> void:
	playing = false
