# enemy.gd
extends CharacterBody2D

#
@export var speed := 35
@export var health := 3
@export var damage_amount = 1
@export var knockback_strength := 120.0
@export var knockback_decay := 500.0 
@onready var contact_area: Area2D = $ContactArea
var player_chase = false
var player: Player = null
var knockback := Vector2.ZERO
var dead := false

#
func _physics_process(delta):
	if dead:
		return
	
	if knockback.length() > 5.0:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, knockback_decay * delta)
		move_and_slide()
		return
	$AnimatedSprite2D.play("jiggle")
	if player_chase and is_instance_valid(player):
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
		$AnimatedSprite2D.flip_h = direction.x > 0
		
		#$AnimatedSprite2D.play("jiggle")
	#else:
		#velocity = Vector2.ZERO
		#$AnimatedSprite2D.play("idle")

#
func take_damage(amount := 1, from_position := Vector2.ZERO):
	if dead:
		return
	health -= amount
	$EnemyHitSound.play()
	if from_position != Vector2.ZERO:
		knockback = from_position.direction_to(global_position) * knockback_strength
	if health <= 0:
		die()
	await get_tree().create_timer(1).timeout

#
func die():
	dead = true
	player_chase = false
	contact_area.set_deferred("monitoring", false)
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

#
func _on_contact_area_body_entered(body):
	if body is Player:
		player = body
		body.hurt(damage_amount)
		print("player touched")

#
func _on_contact_area_body_exited(body):
	if body is Player:
		player = null
