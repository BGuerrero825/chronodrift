extends MeshInstance3D

enum {NONE, ENV = 1, PLAYER = 2, ENEMY = 4}

func _ready():
	var spawner = get_parent().spawner
	$Area3D.set_collision_layer(spawner)
	if spawner == PLAYER:
		$Area3D.set_collision_mask(ENV | ENEMY)
	elif spawner == ENEMY:
		$Area3D.set_collision_mask(ENV | PLAYER)
