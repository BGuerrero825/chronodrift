extends Node


@onready var inverted := true
@onready var sfx_volume := 50
@onready var music_volume := 50


func convert_percentage_to_decibels(percent: float) -> float:
    var scale : float = 20.0
    var divisor : float = 50.0
    return scale * log(percent / divisor) / log(10)
