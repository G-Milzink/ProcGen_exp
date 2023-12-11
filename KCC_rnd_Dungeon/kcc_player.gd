extends CharacterBody2D

var direction = Vector2.ZERO

@export var speed = 100.0


func _physics_process(delta):

	direction.x = Input.get_axis("left", "right")
	direction.y = Input.get_axis("up", "down")
	if direction:
		velocity.x = direction.x * speed
		velocity.y = direction.y * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
	move_and_slide()
