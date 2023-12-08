extends Node2D

@export var noise: FastNoiseLite

var size = 1000

var min = 0.0
var max = 0.0
var value = 0.0

func _process(delta):
	
	if Input.is_action_just_pressed("ui_cancel"):
		noise.seed = randi()
		for x in range(size):
			for y in range(size):
				value =  noise.get_noise_2d(x,y)
				value = round((((value + 1.0) * 0.5 ) * 100.0) / 25.0)
				if value == 0:
					print("0")

