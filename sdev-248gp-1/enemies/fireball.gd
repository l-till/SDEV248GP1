# fireball.gd
extends Area2D

@export var speed := 90.0
@export var damage_amount = 1
var direction := Vector2.RIGHT



func _physics_process(delta):
	position += direction * speed * delta


func _on_body_entered(body):
	if body is Player:
		body.hurt(damage_amount)
		print("player torched")
	queue_free()
