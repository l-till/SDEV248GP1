# game_over.gd
extends Node


func _ready():
	await get_tree().create_timer(2).timeout
	$AnimatedSprite2D.play("fate")
	await get_tree().create_timer(7).timeout
	GameState.restart()
