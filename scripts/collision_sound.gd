extends AudioStreamPlayer3D


func collide(collision_position: Vector3) -> void:
	position = collision_position
	if playing:
		return
	play()


func stop_colliding() -> void:
	playing = false
