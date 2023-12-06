extends Camera2D

@export var camera_speed = 2.0

var movement = Vector2.ZERO


func _process(delta):
	movement.x = Input.get_axis("right", "left")
	movement.y = Input.get_axis("down", "up")
	
	if movement:
		position.x -= movement.x * camera_speed
		position.y -= movement.y * camera_speed

