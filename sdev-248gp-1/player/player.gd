# player.gd
extends CharacterBody2D

class_name Player

signal life_changed(new_life)

# Enums
enum PlayerState {IDLE, WALKING, ATTACKING, ROLLING, STUNNED, DEAD }

# Constants


# Variables
var speed := 100
var player_state = PlayerState.IDLE
var last_direction := Vector2.DOWN
var movable = true
var life = 3: set = set_life
@onready var hit_pivot: Node2D = $HitPivot
@onready var sword_hitbox: Area2D = $HitPivot/SwordHitbox

#
func _ready():
	GameState.on_trigger_player_spawn.connect(_on_spawn)
	sword_hitbox.body_entered.connect(_on_sword_hit)
	sword_hitbox.monitoring = false
	change_state(PlayerState.IDLE)

#
func set_life(value):
	life = value
	life_changed.emit(life)
	if life <= 0:
		change_state(PlayerState.DEAD)

#
func _on_spawn(position: Vector2, direction: String):
	global_position = position
	$AnimatedSprite2D.play("walk_" + direction)
	$AnimatedSprite2D.stop

#
func change_state(new_state):
	player_state = new_state
	if new_state == PlayerState.DEAD:
		velocity = Vector2.ZERO

#
func _physics_process(delta):
	# cant move if attacking, stunned, or dead
	if player_state in [PlayerState.ATTACKING, PlayerState.STUNNED, PlayerState.DEAD]:
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
	var facing = get_facing()
	hit_pivot.rotation = last_direction.angle()
	sword_hitbox.set_deferred("monitoring", true)

	$AnimatedSprite2D.play("attack_" + facing)
	await $AnimatedSprite2D.animation_finished

	sword_hitbox.set_deferred("monitoring", false)
	if player_state != PlayerState.DEAD:
		change_state(PlayerState.IDLE)

func _on_sword_hit(body):
	if body != self and body.has_method("take_damage"):
		body.take_damage(1)

# function for animation
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
