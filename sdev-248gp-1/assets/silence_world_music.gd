extends Node

@export var pause_instead_of_stop: bool = false

func _ready() -> void:
	if pause_instead_of_stop:
		WorldMusic.stream_paused = true
	else:
		WorldMusic.stop()

func _exit_tree() -> void:
	if pause_instead_of_stop:
		WorldMusic.stream_paused = false
	else:
		if not WorldMusic.playing:
			WorldMusic.play()
