extends Node2D

@onready var tile_map = $TileMap
@onready var player = $IB_Player

@export var width = 64
@export var height = 64
@export var sea_level = 0

@export var moisture: FastNoiseLite
@export var tempurature: FastNoiseLite
@export var altitude: FastNoiseLite
var loaded_chunks = []
var player_tile_pos

func _ready():
	moisture.seed = randi()
	tempurature.seed = randi()
	altitude.seed = randi()

func _process(delta):
	player_tile_pos = tile_map.local_to_map(player.position)
	
	_generate_chunk(player_tile_pos)
	#_unloadDistantChunks(player_tile_pos)

func _generate_chunk(player_position):
	var chunk = []
	for x in range(width):
		for y in range(height):
			
			var pos = Vector2(player_position.x - (width/2.0) + x, player_position.y - (height/2.0) + y)
			var moist = ((moisture.get_noise_2d(pos.x,pos.y) +1) * 0.5)*3
			var temp = ((tempurature.get_noise_2d(pos.x,pos.y) +1) * 0.5)*3
			var alt = altitude.get_noise_2d(pos.x,pos.y) * 10.0
			var atlas_coords = Vector2(floor(moist), floor(temp))
			if alt < sea_level:
				tile_map.set_cell(0,pos,0, Vector2(3,1))
			else:
				tile_map.set_cell(0,pos,0, atlas_coords)
			loaded_chunks.append(Vector2i(player_position.x,player_position.y))

func _getDistance(pos1, pos2):
	var result = pos1 - pos2
	return sqrt(result.x ** 2.0 + result.y ** 2.0)

func _clearChunk(player_position):
	for x in range(width):
		for y in range(height):
			
			var pos = Vector2(player_position.x - (width/2.0) + x, player_position.y - (height/2) + y)
			tile_map.erase_cell(0,pos)

func _unloadDistantChunks(player_position):
	var unload_distance = (width * 2.0) + 1.0
	
	for chunk in loaded_chunks:
		var distance_to_player = _getDistance(chunk, player_position)
		
		if distance_to_player > unload_distance:
			_clearChunk(chunk)
			loaded_chunks.erase(chunk)



