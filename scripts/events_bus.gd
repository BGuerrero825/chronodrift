extends Node

var _player_ref: CharacterBody3D = null

signal player_reached_goal
signal replay_controller_ready

func register_player(player: CharacterBody3D) -> void:
    _player_ref = player

func get_player_ref() -> CharacterBody3D:
    return _player_ref 

func emit_player_reached_goal() -> void:
    player_reached_goal.emit()

func emit_replay_controller_ready() -> void:
    replay_controller_ready.emit()
