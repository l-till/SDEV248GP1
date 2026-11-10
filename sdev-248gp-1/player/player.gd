extends CharacterBody2D

# Enums
enum PlayerState { IDLE, WALKING, ATTACKING, ROLLING, STUNNED }

# Constants


# Variables
var speed := 100
var player_state = PlayerState.IDLE
var last_direction := Vector2.DOWN


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
			anim = "frontIdle"
		elif last_direction.y < 0:
			anim = "backIdle"
		elif last_direction.x < 0:
			anim = "leftIdle"
		elif last_direction.x > 0:
			anim = "rightIdle"
		
	elif player_state == PlayerState.WALKING:
		if direction.y < 0:
			anim = "walkUp"
		if direction.x < 0:
			anim = "walkLeft"
		if direction.x > 0:
			anim = "walkRight"
		if direction.y > 0:
			anim = "walkDown"
			
	if anim != "":
		$AnimatedSprite2D.play(anim)
