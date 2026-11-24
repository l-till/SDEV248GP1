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
const HEAL_ROOMS = ["a1c"]

const OVERWORLD_TRACK = preload("res://assets/River-Dance-Folk-Fantasy-Music(chosic.com) (1).mp3")
const CAVE_TRACK = preload("res://assets/Komiku_-_14_-_Sad_walk_with_sad_melodica(chosic.com).mp3")
const BOSS_TRACK = preload("res://assets/sb_marchofmidnight(chosic.com).mp3")
const ROOM_MUSIC = {
	"title": OVERWORLD_TRACK,
	"intro": OVERWORLD_TRACK,
	"b2": OVERWORLD_TRACK,
	"b2c": CAVE_TRACK,
	"b1": OVERWORLD_TRACK,
	"b1c": CAVE_TRACK,
	"a1": OVERWORLD_TRACK,
	"a1c": CAVE_TRACK,
	"a2": BOSS_TRACK
}

# variables
var spawn_door_tag
var life := START_LIFE: set = set_life
var music_player: AudioStreamPlayer

#
func set_life(value):
	life = max(value, 0)
	life_changed.emit(life)

#
func heal_full():
	life = START_LIFE

#
func reset():
	life = START_LIFE

#
func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

#
func update_room_music(level_tag: String):
	if ROOM_MUSIC.has(level_tag):
		play_music(ROOM_MUSIC[level_tag])

#
func play_music(track: AudioStream):
	if music_player.stream == track and music_player.playing:
		return
	music_player.stream = track
	music_player.play()

#
func stop_music():
	music_player.stop()

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
		if level_tag in HEAL_ROOMS:
			heal_full()
		spawn_door_tag = destination_tag
		update_room_music(level_tag)
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
