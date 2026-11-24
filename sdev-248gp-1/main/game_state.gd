# game_state.gd
extends Node

#
signal on_trigger_player_spawn
signal life_changed

# constants
const title_screen = "res://main/title.tscn"
const game_over_screen = "res://main/game_over.tscn"
const win_screen = "res://main/win.tscn"
const scene_b2 = preload("res://levels/b2.tscn")
const scene_b2c = preload("res://levels/b2c.tscn")
const scene_b1 = preload("res://levels/b1.tscn")
const scene_b1c = preload("res://levels/b1c.tscn")
const scene_a1 = preload("res://levels/a1.tscn")
const scene_a1c = preload("res://levels/a1c.tscn")
const scene_a2 = preload("res://levels/a2.tscn")

const START_LIFE = 3

# variables
var spawn_door_tag
var life := START_LIFE: set = set_life

#
func set_life(value):
	life = max(value, 0)
	life_changed.emit(life)

#
func reset():
	life = START_LIFE

#
func go_to_level(level_tag, destination_tag):
	var scene_to_load
	
	match level_tag:
		"b2":
			scene_to_load = scene_b2
		"b2c":
			scene_to_load = scene_b2c
		"b1":
			scene_to_load = scene_b1
		"b1c":
			scene_to_load = scene_b1c
		"a1":
			scene_to_load = scene_a1
		"a1c":
			scene_to_load = scene_a1c
		"a2":
			scene_to_load = scene_a2
		
	if scene_to_load != null:
		spawn_door_tag = destination_tag
		get_tree().change_scene_to_packed(scene_to_load)

#
func trigger_player_spawn(position: Vector2, direction: String):
	on_trigger_player_spawn.emit(position, direction)

#
func game_over():
	get_tree().change_scene_to_file(game_over_screen)

#
func win():
	get_tree().change_scene_to_file(win_screen)

#
func restart():
	reset()
	get_tree().change_scene_to_file(title_screen)
