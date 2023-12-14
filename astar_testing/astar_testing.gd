extends Node2D

@onready var tile_map = $TileMap

var active_tiles = []
var pathing_points = []

var astar = AStar2D.new()
var tile_data: TileData
var point_id: int
var path: PackedVector2Array

func _ready():
	active_tiles = tile_map.get_used_cells(0)
	for tile in active_tiles:
		tile_data = tile_map.get_cell_tile_data(0,tile)
		point_id = astar.get_available_point_id()
		astar.add_point(point_id,tile)
		if tile_data.get_custom_data("is_wall"):
			astar.set_point_disabled(point_id)
		if tile_data.get_custom_data("is_door"):
			pathing_points.append(point_id)
	print(pathing_points)
	path = astar.get_point_path(78,192)
	print(path)
