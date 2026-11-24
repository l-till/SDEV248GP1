# player.gd
extends CharacterBody2D

class_name Player

# Enums
enum PlayerState {IDLE, WALKING, ATTACKING, ROLLING, STUNNED, DEAD }

# Constants
const HITBOX_POSITIONS := {
	"right": {"pos": Vector2(10, -6),   "rot": 0},
	"down":  {"pos": Vector2(2, 2),   "rot": 90},
	"left":  {"pos": Vector2(-10, -6),  "rot": 0},
	"up":    {"pos": Vector2(-2, -20),  "rot": 90},
}

# Variables
@export var speed := 100
@export var knockback_strength := 120.0
@export var knockback_decay := 500.0 
var player_state = PlayerState.IDLE
var last_direction := Vector2.DOWN
var life = GameState.life
var movable = true
var invincible := false
var knockback := Vector2.ZERO
var enemy_attack_cooldown = true
var hit_this_swing: Array = []
@onready var hit_pivot: Node2D = $HitPivot
@onready var sword_hitbox: Area2D = $HitPivot/SwordHitbox

#
func _ready():
	GameState.on_trigger_player_spawn.connect(_on_spawn)
	sword_hitbox.monitoring = false
	change_state(PlayerState.IDLE)

#
func get_life() -> int:
	return GameState.life

#
func set_life():
	if GameState.life <= 0:
		change_state(PlayerState.DEAD)

#
func _on_spawn(position: Vector2, direction: String):
	global_position = position
	$AnimatedSprite2D.play("walk_" + direction)
	$AnimatedSprite2D.stop()

#
func change_state(new_state):
	player_state = new_state
	if new_state == PlayerState.DEAD:
		velocity = Vector2.ZERO

#
func _physics_process(delta):
	if player_state == PlayerState.STUNNED:
		velocity = velocity.move_toward(Vector2.ZERO, 600 * delta)
		move_and_slide()
		return

	if player_state in [PlayerState.ATTACKING, PlayerState.DEAD]:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if Input.is_action_just_pressed("attack"):
		attack()
		return
	
	var direction = Input.get_vector("left","right","up","down")
	
	if direction == Vector2.ZERO:
		player_state = PlayerState.IDLE
	else:
		player_state = PlayerState.WALKING
		last_direction = direction
	
	velocity = direction * speed
	move_and_slide()
	play_anim(direction)

func get_facing() -> String:
	if abs(last_direction.x) > abs(last_direction.y):
		return "right" if last_direction.x > 0 else "left"
	return "down" if last_direction.y > 0 else "up"

#
func attack():
	change_state(PlayerState.ATTACKING)
	velocity = Vector2.ZERO
	hit_this_swing.clear()
	var facing = get_facing()
	var box = HITBOX_POSITIONS[facing]
	sword_hitbox.position = box["pos"]
	sword_hitbox.rotation_degrees = box["rot"]
	sword_hitbox.set_deferred("monitoring", true)

	$AnimatedSprite2D.play("attack_" + facing)
	await $AnimatedSprite2D.animation_finished

	sword_hitbox.set_deferred("monitoring", false)
	if player_state == PlayerState.ATTACKING:
		change_state(PlayerState.IDLE)

func _on_sword_hit(body):
	if body == self or body in hit_this_swing:
			return
	if body.has_method("take_damage"):
		hit_this_swing.append(body)
		body.take_damage(1, global_position)

#
func play_anim(direction: Vector2):
	var anim = ""
	if player_state == PlayerState.IDLE:
		anim = "idle_" + get_facing()
		
	elif player_state == PlayerState.WALKING:
		if direction.y < 0:
			anim = "walk_up"
		if direction.x < 0:
			anim = "walk_left"
		if direction.x > 0:
			anim = "walk_right"
		if direction.y > 0:
			anim = "walk_down"
			
	if anim != "":
		$AnimatedSprite2D.play(anim)

#
func _on_hurt_box_body_entered(body):
	if body.is_in_group("enemies"):
		hurt(body.damage_amount)

#
func hurt(hurt_amount: int, from_position := Vector2.ZERO):
	if invincible or player_state == PlayerState.DEAD:
		return
	print("player took damage")
	invincible = true
	GameState.life -= hurt_amount
	if from_position != Vector2.ZERO:
		knockback = from_position.direction_to(global_position) * knockback_strength
	sword_hitbox.set_deferred("monitoring", false)
	await get_tree().create_timer(0.75).timeout
	invincible = false
	if life <= 0:
		die()

#
func die():
#	$AnimatedSprite2D.play("death")
#	await $AnimatedSprite2D.animation_finished
	GameState.game_over()
