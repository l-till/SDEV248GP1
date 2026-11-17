# enemy.gd
extends CharacterBody2D

#
@export var speed := 40
@export var health := 3
@export var knockback_strength := 120.0
@export var knockback_decay := 500.0 

#
#var facing = 1
var player_chase = false
var player: Player = null
var knockback := Vector2.ZERO
var dead := false

#
func _physics_process(delta):
	if knockback.length() > 5.0:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, knockback_decay * delta)
		move_and_slide()
		return
	
	if player_chase and is_instance_valid(player):
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
		$AnimatedSprite2D.flip_h = direction.x < 0
		#$AnimatedSprite2D.play("hop")
	else:
		velocity = Vector2.ZERO
		#$AnimatedSprite2D.play("idle")

#
func take_damage(amount := 1, from_position := Vector2.ZERO):
	if dead:
		return
	
	health -= amount
	$EnemyHitSound.play()
	
	if from_position != Vector2.ZERO:
		knockback = from_position.direction_to(global_position) * knockback_strength
	
	if health > 0:
		
		$AnimatedSprite2D.modulate = Color.BLACK
		create_tween().tween_property($AnimatedSprite2D, "modulate", Color.WHITE, 0.2)
		return
	
	die()

#
func die():
	dead = true
	player_chase = false
	$CollisionShape2D.set_deferred("disabled", true)
	#$AnimationPlayer.play("death")
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

#
func _on_detection_area_body_entered(body):
	if body is Player:
		player = body
		player_chase = true

#
func _on_detection_area_body_exited(body):
	if body is Player:
		player = null
		player_chase = false
	
