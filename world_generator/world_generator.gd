extends Node2D

var map_width = 3000
var map_height = 3000

var sea_level = -0.25
var mountain_level = 0.5
var absolute_zero = 0.1
var freezing_point = 0.6

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

var variation: float

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
			variation = noise_map.get_noise_2d(x,y)
			
			alt = altitude.get_noise_2d(x,y)
			temp = temp_img.get_pixel(x,y).r + variation * 0.3
			humid = humidity.get_noise_2d(x,y)
			
			if alt < sea_level:
				tile_map.set_cell(0,pos,0,Vector2(0,0))
				tile.x = clamp(-(ceil((alt*-4)*2)-3)+3, 0.0, 3.0)
				tile.y = 8
				tile_map.set_cell(0,pos,0,tile)
			elif alt > mountain_level:
				tile.x = clamp(round((((alt-0.5)*8)/3)*4)+4, 4.0, 7.0)
				tile.y = 8
				tile_map.set_cell(0,pos,0,tile)
			else:
					tile.x = clamp(floor((humid+1.0*0.5)*8),0.0,7.0)
					tile.y = temp*7
					tile_map.set_cell(0,pos,0,tile)
