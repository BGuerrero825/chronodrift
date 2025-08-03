class_name Goal
extends Area3D

func _on_body_entered(body:Node3D) -> void:
	if body is PlayerShip:
		Debug.log("player ship entered")
		EventsBus.emit_player_reached_goal()
