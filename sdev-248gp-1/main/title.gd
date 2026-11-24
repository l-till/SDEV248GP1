# title.gd
extends Control

func _ready() -> void:
	$Backdrop/Viewport/A1Background/Player.set_physics_process(false)
	$CenterContainer/Menu/PlayButton.grab_focus()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://main/intro.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
