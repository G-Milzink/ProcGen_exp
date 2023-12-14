extends Node2D

@onready var tile_map = $TileMap

var active_tiles = []
var pathing_points = []

var astar = AStarGrid2D.new()
var tile_data: TileData
var point_id: int
var path: PackedVector2Array

func _ready():
	active_tiles = tile_map.get_used_cells(0)
	astar.region = Rect2(0,0,21, 16)
	astar.cell_size = Vector2(32,32)
	astar.set_diagonal_mode(AStarGrid2D.DIAGONAL_MODE_NEVER)
	astar.update()
	
	for tile in active_tiles:
		tile_data = tile_map.get_cell_tile_data(0,tile)
		if tile_data.get_custom_data("is_door"):
			pathing_points.append(tile)
		if tile_data.get_custom_data("is_wall"):
			astar.set_point_solid(tile,true)
	path = astar.get_id_path(pathing_points[0], pathing_points[1])
	for tile in path:
		tile_map.erase_cell(0,tile)

