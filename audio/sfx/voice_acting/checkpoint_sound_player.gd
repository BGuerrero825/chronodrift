extends AudioStreamPlayer3D

@onready var checkpoint_sounds : Array[AudioStreamWAV]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	checkpoint_sounds.append(preload("res://audio/sfx/voice_acting/checkpoint_1.wav"))
	checkpoint_sounds.append(preload("res://audio/sfx/voice_acting/checkpoint_2.wav"))
	checkpoint_sounds.append(preload("res://audio/sfx/voice_acting/checkpoint_3.wav"))


func checkpoint() -> void:
	stream = checkpoint_sounds.pick_random()
	playing = true

