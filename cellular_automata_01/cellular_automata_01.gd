extends Node2D

@onready var tile_map = $TileMap
@onready var noise_gen = $NoiseGen
@onready var iterations_display = $CanvasLayer/MarginContainer/IterationsDisplay

@export var width = 4
@export var height = 4
@export var noise_cutoff_point = 0.0
@export var min_nr_neighbours = 4
@export var nr_of_iterations = 0


var noise_grid: PackedVector2Array
var iterated_grid: PackedVector2Array
var tile_grid: PackedVector2Array
var iterations_done = 0

var offset_x
var offset_y

func _ready():
	offset_x = -width/2
	offset_y = -height/2
	_SetFloorLayer()
	_generateNoiseGrid()
	for i in nr_of_iterations:
		_iterateGrid()

func _on_regenerate_pressed():
	iterations_done = 0
	noise_gen._newSeed()
	_generateNoiseGrid()
	
func _on_iterate_pressed():
	_iterateGrid()

func _process(delta):
	_updateIterationsDisplay()
	if Input.is_action_just_pressed("iterate"):
		_iterateGrid()

func _SetFloorLayer():
	for x in width:
		for y in height:
			var pos = (Vector2(x+offset_x, y+offset_y))
			tile_map.set_cell(0,pos,4,Vector2(2,3))

func _generateNoiseGrid():
	noise_grid.clear()
	for x in width:
		for y in width:
			var pos = (Vector2(x+offset_x, y+offset_y))
			var value = noise_gen._getNoise(pos)
			if value >= noise_cutoff_point:
				noise_grid.append(pos)
	tile_map.clear_layer(1)
	tile_map.set_cells_terrain_connect(1,noise_grid,0,0,false)

func _iterateGrid():
	var tile
	var neighbour
	var nr_of_neighbours
	iterated_grid.clear()
	for x in width:
		for y in width:
			tile = (Vector2(x+offset_x, y+offset_y))
			nr_of_neighbours = 0
			neighbour = tile_map.get_neighbor_cell(tile,TileSet.CELL_NEIGHBOR_TOP_SIDE)
			if tile_map.get_cell_tile_data(1,neighbour) != null:
				nr_of_neighbours += 1
			neighbour = tile_map.get_neighbor_cell(tile,TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER)
			if tile_map.get_cell_tile_data(1,neighbour) != null:
				nr_of_neighbours += 1
			neighbour = tile_map.get_neighbor_cell(tile,TileSet.CELL_NEIGHBOR_RIGHT_SIDE)
			if tile_map.get_cell_tile_data(1,neighbour) != null:
				nr_of_neighbours += 1
			neighbour = tile_map.get_neighbor_cell(tile,TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER)
			if tile_map.get_cell_tile_data(1,neighbour) != null:
				nr_of_neighbours += 1
			neighbour = tile_map.get_neighbor_cell(tile,TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
			if tile_map.get_cell_tile_data(1,neighbour) != null:
				nr_of_neighbours += 1
			neighbour = tile_map.get_neighbor_cell(tile,TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER)
			if tile_map.get_cell_tile_data(1,neighbour) != null:
				nr_of_neighbours += 1
			neighbour = tile_map.get_neighbor_cell(tile,TileSet.CELL_NEIGHBOR_LEFT_SIDE)
			if tile_map.get_cell_tile_data(1,neighbour) != null:
				nr_of_neighbours += 1
			neighbour = tile_map.get_neighbor_cell(tile,TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER)
			if tile_map.get_cell_tile_data(1,neighbour) != null:
				nr_of_neighbours += 1
			if nr_of_neighbours >= min_nr_neighbours:
				iterated_grid.append(Vector2(tile))
	tile_map.clear_layer(1)
	tile_map.set_cells_terrain_connect(1,iterated_grid,0,0,false)
	iterations_done += 1

func _updateIterationsDisplay():
	iterations_display.clear()
	iterations_display.add_text("Iterations: ")
	iterations_display.add_text(str(iterations_done))


