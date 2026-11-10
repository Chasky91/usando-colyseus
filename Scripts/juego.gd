extends Node2D

var pos := Vector2(100, 100)

func _process(delta):
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir != Vector2.ZERO:
		pos += dir * 200 * delta
		Network.mover(pos)
