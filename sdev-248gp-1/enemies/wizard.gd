# wizard.gd
extends CharacterBody2D

#
@export var health := 3
@export var damage_amount := 1
@export var fireball_scene: PackedScene
@export var fade_time := 0.4                  # seconds to fade in or out
@export var windup_time := 0.5                # visible before shooting
@export var recover_time := 0.6               # visible after shooting
@export var hidden_time := 1.0                # invisible between appearances
@export var min_distance := 48.0              # closest he appears to the player
@export var max_distance := 128.0             # farthest he appears from the player

@onready var contact_area: Area2D = $ContactArea
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: Player = null
var cycle: Tween
var spawn_points: Array[Vector2] = []
var vulnerable := false
var dead := false


#
func _ready():
	sprite.play("jiggle")
	sprite.modulate.a = 0.0
	_set_vulnerable(false)
	_collect_spawn_points()
	_find_player()
	_start_cycle()

#
func _collect_spawn_points():
	for layer in get_tree().get_nodes_in_group("wizard_spawns"):
		if layer is TileMapLayer:
			layer.hide()   # markers visible in the editor, hidden in-game
			for cell in layer.get_used_cells():
				var data = layer.get_cell_tile_data(cell)
				if data and data.get_custom_data("type") == "wizard_spawn":
					spawn_points.append(layer.to_global(layer.map_to_local(cell)))

#
func _find_player():
	player = get_tree().get_first_node_in_group("player") as Player


# the repeating appear / shoot / vanish loop
func _start_cycle():
	if cycle and cycle.is_valid():
		return
	cycle = create_tween().set_loops()
	cycle.tween_callback(_teleport)
	cycle.tween_property(sprite, "modulate:a", 1.0, fade_time)
	cycle.tween_callback(_set_vulnerable.bind(true))
	cycle.tween_interval(windup_time)
	cycle.tween_callback(_shoot)
	cycle.tween_interval(recover_time)
	cycle.tween_callback(_set_vulnerable.bind(false))
	cycle.tween_property(sprite, "modulate:a", 0.0, fade_time)
	cycle.tween_interval(hidden_time)


# only hittable and harmful while visible
func _set_vulnerable(on: bool):
	vulnerable = on
	$CollisionShape2D.set_deferred("disabled", not on)
	contact_area.set_deferred("monitoring", on)


# jumps to a marker tile near the player
func _teleport():
	if not is_instance_valid(player):
		_find_player()
	if spawn_points.is_empty() or not is_instance_valid(player):
		return
	var options = spawn_points.filter(_is_good_spot)
	if options.is_empty():
		global_position = _nearest_spawn()   # nothing in range: use the closest marker
	else:
		global_position = options.pick_random()


# in the right distance band from the player, and not where he already is
func _is_good_spot(p: Vector2) -> bool:
	var d = p.distance_to(player.global_position)
	return d >= min_distance and d <= max_distance and p.distance_to(global_position) > 1.0


#
func _nearest_spawn() -> Vector2:
	var best := Vector2.INF
	for p in spawn_points:
		if p.distance_to(global_position) <= 1.0:
			continue   # skip the spot he's already on
		if best == Vector2.INF or p.distance_to(player.global_position) < best.distance_to(player.global_position):
			best = p
	return best if best != Vector2.INF else global_position


#
func _shoot():
	if not is_instance_valid(player) or fireball_scene == null:
		return
	var dir = global_position.direction_to(player.global_position)
	sprite.flip_h = dir.x > 0
	var fireball = fireball_scene.instantiate()
	get_parent().add_child(fireball)   # parent, so it survives if the wizard dies
	fireball.global_position = global_position
	fireball.direction = dir


#
func take_damage(amount := 1, _from_position := Vector2.ZERO):
	if dead or not vulnerable:
		return
	health -= amount
	$EnemyHitSound.play()
	if health <= 0:
		die()


#
func die():
	dead = true
	if cycle:
		cycle.kill()
	_set_vulnerable(false)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
	GameState.win()


#
func _on_contact_area_body_entered(body):
	if body is Player:
		body.hurt(damage_amount)


# kept as an empty stub so the existing signal connection doesn't break
func _on_contact_area_body_exited(_body):
	pass
