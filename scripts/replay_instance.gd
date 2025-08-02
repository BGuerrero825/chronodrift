class_name ReplayData
extends Resource

@export var replay_id := -1

@export var position_tracker: PackedVector3Array = []
@export var transform_tracker: Array[Transform3D] = []

func record_frame(player_ref: PlayerShip) -> void:
    assert(player_ref != null, "attempting to record when no player_ref is set")
    position_tracker.append(player_ref.global_position)
    transform_tracker.append(player_ref.global_transform)
