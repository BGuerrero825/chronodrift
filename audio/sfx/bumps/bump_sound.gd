extends AudioStreamPlayer3D

@onready var bumpsounds : Array[AudioStreamWAV]
@onready var go_ahead := true


func _ready() -> void:
	bumpsounds.append(preload("res://audio/sfx/bumps/bump_1.wav"))
	bumpsounds.append(preload("res://audio/sfx/bumps/bump_2.wav"))
	bumpsounds.append(preload("res://audio/sfx/bumps/bump_3.wav"))


func bump() -> void:
	if go_ahead:
		go_ahead = false
		stream = bumpsounds.pick_random()
		playing = true
		await get_tree().create_timer(0.5).timeout
		go_ahead = true

