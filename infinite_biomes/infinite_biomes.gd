extends Node2D

@onready var tile_map = $TileMap
@onready var player = $IB_Player

@export var width = 20
@export var height = 20
@export var sea_level = 0

@export var moisture: FastNoiseLite
@export var tempurature: FastNoiseLite
@export var altitude: FastNoiseLite
var player_tile_pos

func _ready():
	
	moisture.seed = randi()
	tempurature.seed = randi()
	altitude.seed = randi()

func _process(delta):
	player_tile_pos = tile_map.local_to_map(player.position)
	
	_generate_chunk(player_tile_pos)

func _generate_chunk(player_position):
	for x in range(width):
		for y in range(height):
			
			var pos = Vector2(player_position.x - (width/2.0) + x, player_position.y - (height/2.0) + y)
			var moist = moisture.get_noise_2d(pos.x,pos.y)
			moist = round((((moist + 1.0) * 0.5 ) * 100.0) / 25.0)
			var temp = tempurature.get_noise_2d(pos.x,pos.y)
			temp = round((((temp + 1.0) * 0.5 ) * 100.0) / 25.0)
			var alt = altitude.get_noise_2d(pos.x,pos.y) * 10.0
			var atlas_coords = Vector2(moist,temp)
			if alt < sea_level:
				tile_map.set_cell(0,pos,0, Vector2(3,1))
			else:
				tile_map.set_cell(0,pos,0, atlas_coords)
