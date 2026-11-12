# player.gd
extends CharacterBody2D

class_name Player

# Enums
enum PlayerState { IDLE, WALKING, ATTACKING, ROLLING, STUNNED }

# Constants


# Variables
var speed := 100
var player_state = PlayerState.IDLE
var last_direction := Vector2.DOWN
var movable = true

#
func _ready():
	GameState.on_trigger_player_spawn.connect(_on_spawn)

#
func _on_spawn(position: Vector2, direction: String):
	global_position = position
	$AnimatedSprite2D.play("walk_" + direction)
	$AnimatedSprite2D.stop
	

# function for movement
func _physics_process(delta):
	var direction = Input.get_vector("left","right","up","down")
	
	if direction == Vector2.ZERO:
		player_state = PlayerState.IDLE
	else:
		player_state = PlayerState.WALKING
		last_direction = direction
		
	velocity = direction * speed
	
	move_and_slide()
	play_anim(direction)
	
# function for animation
func play_anim(direction: Vector2):
	var anim = ""
	if player_state == PlayerState.IDLE:
		if last_direction.y > 0:
			anim = "idle_down"
		elif last_direction.y < 0:
			anim = "idle_up"
		elif last_direction.x < 0:
			anim = "idle_left"
		elif last_direction.x > 0:
			anim = "idle_right"
		
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
