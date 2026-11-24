extends Control

var _transitioning := false

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	var pressed := false
	if event is InputEventKey:
		pressed = event.pressed and not event.echo
	elif event is InputEventMouseButton:
		pressed = event.pressed
	elif event is InputEventJoypadButton:
		pressed = event.pressed

	if pressed and not _transitioning:
		_transitioning = true
		GameState.restart()
