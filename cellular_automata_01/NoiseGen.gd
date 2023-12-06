extends Node

@export var noise = FastNoiseLite.new()

func _ready():
	var s = randi()
	print(s)
	noise.seed = s

func _newSeed():
	var s = randi()
	print(s)
	noise.seed = s

func _getNoise(pos):
	var value = noise.get_noise_2d(pos.x,pos.y)
	return value
