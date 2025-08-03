extends Node

var _player_ref: PlayerShip = null
var _replay_controller_ref: ReplayController = null

signal player_reached_goal
signal replay_controller_ready
signal player_destroyed
signal player_triggered_lap_reset
signal player_triggered_level_reset
signal start_delay_triggered(seconds)

func register_replay_controller(controller: ReplayController) -> void:
    _replay_controller_ref = controller

func get_replay_controller_ref() -> ReplayController:
    return _replay_controller_ref

func register_player(player: PlayerShip) -> void:
    _player_ref = player

func get_player_ref() -> PlayerShip:
    return _player_ref 

func emit_player_reached_goal() -> void:
    player_reached_goal.emit()

func emit_replay_controller_ready() -> void:
    replay_controller_ready.emit()

func emit_player_destroyed() -> void:
    player_destroyed.emit()

func emit_player_triggered_lap_reset() -> void:
    player_triggered_lap_reset.emit()

func emit_player_triggered_level_reset() -> void:
    player_triggered_level_reset.emit()

func emit_start_delay_triggered(seconds) -> void:
    start_delay_triggered.emit(seconds)
