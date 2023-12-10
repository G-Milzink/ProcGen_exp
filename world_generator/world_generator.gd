extends Node2D

@export var map_width = 100
@export var map_height = 100

@export var temperature: GradientTexture2D
@export var altitude: FastNoiseLite

@onready var tile_map = $TileMap

var temp_img: Image
var temp: float
var alt: float

func _ready():
	temp_img = temperature.get_image()
	

func _process(delta):
	pass

func _generateOceans():
	for x in map_width:
		for y in map_height:
			temp = temp_img.get_pixel(x-1,y-1).r
			alt = altitude.get_noise_2d(x,y)
			