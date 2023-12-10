extends Node2D

@export var map_width = 1000
@export var map_height = 1000

@export var sea_level = -.25
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


	for x in map_width:
		for y in map_height:
			pos.x = x - map_width/2.0
			pos.y = y - map_height/2.0
			temp = temp_img.get_pixel(x,y).r * noise_map.get_noise_2d(x,y)
			alt = altitude.get_noise_2d(x,y)
			if alt < sea_level:
					if alt < 2.0 * sea_level:
						tile_map.set_cell(0,pos,0,Vector2i(2,0))
					elif alt < 1.5 * sea_level:
						tile_map.set_cell(0,pos,0,Vector2i(1,0))
					else:
						tile_map.set_cell(0,pos,0,Vector2i(0,0))
			elif alt > mountain_level:
				if alt > 1.5 * mountain_level:
					tile_map.set_cell(0,pos,0,Vector2i(4,0))
				elif alt > 1.25 * mountain_level:
					tile_map.set_cell(0,pos,0,Vector2i(4,1))
				else:
					tile_map.set_cell(0,pos,0,Vector2i(4,2))
			else:
				tile.x = floor(temp*-3)+3
				humid = humidity.get_noise_2d(x,y)
				tile.y = ceil(((humid+1)*0.5)*-3)+3
				tile_map.set_cell(0,pos,0,tile)
	print("done!")
