extends Node2D

@onready var tile_patterns = $TilePatterns
@onready var tile_map = $TileMap

var room1n: TileMapPattern
var room1e: TileMapPattern
var room1s: TileMapPattern
var room1w: TileMapPattern

var loot_tiles: Array
var spawn_tiles: Array
var door_tiles: Array

var astar_grid = AStarGrid2D.new()
var path: PackedVector2Array

const LOOT_TILE = Vector2(3,2)
const SPAWN_TILE = Vector2(3,1)
const DOOR_TILE = Vector2(1,1)

func _input(event):
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()

func _ready():
	getPatterns()
	placeRooms()
	iterateMap()
	createPaths()


func getPatterns():
	var pattern_tiles = []
	#room1_north_entry:
	pattern_tiles.clear()
	for x in range(0,7):
		for y in range(0,7):
			pattern_tiles.append(Vector2i(x,y))
	room1n = tile_patterns.get_pattern(0,pattern_tiles)
	#room1_east_entry:
	pattern_tiles.clear()
	for x in range(7,14):
		for y in range(0,7):
			pattern_tiles.append(Vector2i(x,y))
	room1e = tile_patterns.get_pattern(0,pattern_tiles)
#room1_south_entry:
	pattern_tiles.clear()
	for x in range(14,21):
		for y in range(0,7):
			pattern_tiles.append(Vector2i(x,y))
	room1s = tile_patterns.get_pattern(0,pattern_tiles)
#room1_south_entry:
	pattern_tiles.clear()
	for x in range(21,28):
		for y in range(0,7):
			pattern_tiles.append(Vector2i(x,y))
	room1w = tile_patterns.get_pattern(0,pattern_tiles)

func placeRooms():
	var rng: int
	var select: TileMapPattern
	var pos
	#Spawn a room
	rng = randi_range(1,4)
	match rng:
		1:
			select = room1n
		2:
			select = room1e
		3:
			select = room1s
		4:
			select = room1w
	tile_map.set_pattern(0,Vector2i(2,2),select)
	#Spawn a second room...
	rng = randi_range(1,4)
	match rng:
		1:
			select = room1n
		2:
			select = room1e
		3:
			select = room1s
		4:
			select = room1w
	pos = Vector2i(randi_range(10,20),randi_range(10,20))
	tile_map.set_pattern(0,pos,select)
	#Spawn a third room...
	rng = randi_range(1,4)
	match rng:
		1:
			select = room1n
		2:
			select = room1e
		3:
			select = room1s
		4:
			select = room1w
	pos = Vector2i(randi_range(21,40),randi_range(21,40))
	tile_map.set_pattern(0,pos,select)

func iterateMap():
	var td: TileData
	var rng: int
	for tile in tile_map.get_used_cells(0):
		td = tile_map.get_cell_tile_data(0,tile)
		if td.get_custom_data("has_content"):
			rng = randi() % 100 + 1
			if rng > 50:
				tile_map.set_cell(0,tile,0,LOOT_TILE)
				loot_tiles.append(tile)
			else:
				tile_map.set_cell(0,tile,0,SPAWN_TILE)
				spawn_tiles.append(tile)
		elif td.get_custom_data("is_door"):
			tile_map.set_cell(0,tile,0,DOOR_TILE)
			door_tiles.append(tile)

func createPaths():
	var td: TileData
	astar_grid.region = Rect2(0,0,100, 100)
	astar_grid.cell_size = Vector2(32,32)
	astar_grid.set_default_compute_heuristic(1)
	astar_grid.set_default_estimate_heuristic(1)
	astar_grid.set_diagonal_mode(AStarGrid2D.DIAGONAL_MODE_NEVER)
	astar_grid.update()
	
	for tile in tile_map.get_used_cells(0):
		td = tile_map.get_cell_tile_data(0,tile)
		if td.get_custom_data("is_wall"):
			astar_grid.set_point_solid(tile,true)
	path = astar_grid.get_id_path(door_tiles[0], door_tiles[1])
	tile_map.set_cells_terrain_connect(0,path,0,0,false)
	path = astar_grid.get_id_path(door_tiles[0], door_tiles[2])
	tile_map.set_cells_terrain_connect(0,path,0,0,false)
