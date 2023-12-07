extends Node2D

@onready var tile_map = $TileMap
@onready var noise_gen = $NoiseGens
@onready var player = $IB_Player

@export var width = 32
@export var height = 32
@export var sea_level = 0

var loaded_chunks = []
var player_tile_pos

func _process(delta):
	player_tile_pos = tile_map.local_to_map(player.position)
	
	_generate_chunk(player_tile_pos)
	_unloadDistantChunks(player_tile_pos)

func _generate_chunk(player_position):
	for x in width:
		for y in height:
			
			var pos = Vector2(player_position.x - (width/2.0) + x, player_position.y - (height/2.0) + y)
			var moist = noise_gen._getMoisture(pos) * 10.0
			var temp = noise_gen._getTemperature(pos) * 10.0
			var alt = noise_gen._getAltitude(pos) * 10.0
			var atlas_coords = Vector2((moist + 10) / 20, (temp + 10) / 20)
			
			if alt < sea_level:
				tile_map.set_cell(0,pos,0, Vector2(3,3))
			else:
				tile_map.set_cell(0,pos,0, atlas_coords)
			
			if Vector2(player_position.x,player_position.y) not in loaded_chunks:
				loaded_chunks.append(Vector2i(player_position.x,player_position.y))

func _getDistance(pos1, pos2):
	var result = pos1 - pos2
	return sqrt(result.x ** 2.0 + result.y ** 2.0)

func _clearChunk(player_position):
	for x in width:
		for y in height:
			
			var pos = Vector2(player_position.x - (width/2.0) + x, player_position.y - (height/2) + y)
			tile_map.set_cell(0,pos,-1, Vector2(-1,-1))

func _unloadDistantChunks(player_position):
	var unload_distance = (width * 2.0) + 1.0
	
	for chunk in loaded_chunks:
		var distance_to_player = _getDistance(chunk, player_position)
		
		if distance_to_player > unload_distance:
			_clearChunk(chunk)
			loaded_chunks.erase(chunk)



