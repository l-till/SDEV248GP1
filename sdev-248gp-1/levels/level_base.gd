# level_base.gd
extends Node2D

#
func _ready():
	if GameState.spawn_door_tag != null:
		_on_level_spawn(GameState.spawn_door_tag)

func _on_level_spawn(destination_tag: String):
	var door_path = "Doors/Door_" + destination_tag
	var door = get_node(door_path) as Door
	GameState.trigger_player_spawn(door.spawn.global_position, door.spawn_direction)
