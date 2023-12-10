extends Node2D

@export var map_width = 1000
@export var map_height = 1000

@export var sea_level = 0.5
@export var mountain_level = 0.5
@export var absolute_zero = 0.1
@export var freezing_point = 0.6

@export var temperature: GradientTexture2D
@export var altitude: FastNoiseLite
@export var humidity: FastNoiseLite
@export var noise_map: FastNoiseLite

@onready var tile_map = $TileMap
var debug_tile = Vector2(4,4)

var temp_img: Image
var temp: float
var alt: float
var humid: float

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	temperature.set_height(map_height+1)
	temperature.set_width(map_width+1)
	temp_img = temperature.get_image()
	_generateOceans()
	

func _generateOceans():
	altitude.seed = randi()
	humidity.seed = randi()
	noise_map.seed = randi()

	var pos = Vector2.ZERO
	var tile = Vector2.ZERO

	# Iterate over grid:
	for x in map_width:
		for y in map_height:
			# Center map on grid:
			pos.x = x - map_width/2.0
			pos.y = y - map_height/2.0
			# Get map parameters: 
			alt = altitude.get_noise_2d(x,y)

			if alt < sea_level:
				tile_map.set_cell(0,pos,0,Vector2(0,0))
				tile.x = clamp(-(ceil((alt*-4)*2)-3)+3, 0.0, 3.0)
				tile.y = 0
				tile_map.set_cell(0,pos,0,tile)
			elif alt > mountain_level:
				print((((alt-0.5)*8)/3)*4)
				tile_map.set_cell(0,pos,0,Vector2(4,0))
