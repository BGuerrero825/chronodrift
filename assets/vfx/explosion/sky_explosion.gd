class_name SkyExplosion
extends Node3D

@onready var debris : GPUParticles3D = %Debris
@onready var fire : GPUParticles3D = %Fire


func explode() -> void:
	debris.emitting = true
	fire.emitting = true
