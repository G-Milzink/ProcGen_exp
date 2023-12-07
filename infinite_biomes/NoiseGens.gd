extends Node

var moisture = FastNoiseLite.new()
var tempurature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()

func _ready():
	moisture.seed = randi()
	tempurature.seed = randi()
	altitude.seed = randi()
	
	altitude.frequency = 0.01

func _getMoisture(pos):
	var value = moisture.get_noise_2d(pos.x,pos.y)
	return value

func _getTemperature(pos):
	var value = tempurature.get_noise_2d(pos.x,pos.y)
	return value

func _getAltitude(pos):
	var value = altitude.get_noise_2d(pos.x,pos.y)
	return value
