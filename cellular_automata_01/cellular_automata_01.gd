extends Node2D

#region Node References
@onready var tile_map = $TileMap
@onready var noise_gen = $NoiseGen
@onready var iterations_display = $CanvasLayer/MarginContainer/IterationsDisplay
@onready var width_display = $CanvasLayer/MarginContainer/WidthDisplay
@onready var height_display = $CanvasLayer/MarginContainer/HeightDisplay
@onready var tile_chance_display = $CanvasLayer/MarginContainer/TileChanceDisplay
@onready var neighbours_display = $CanvasLayer/MarginContainer/NeighboursDisplay
@onready var noise_freq_display = $CanvasLayer/MarginContainer/NoiseFreqDisplay
#endregion

#region Exported Variables
@export var width = 4
@export var height = 4
@export_range(05,95) var noise_cutoff_point = 50
@export var min_nr_neighbours = 4
@export var nr_of_iterations = 0
@export var noise_frequency = 0.2
#endregion

#region Function Variables
var noise_grid: PackedVector2Array
var iterated_grid: PackedVector2Array
var tile_grid: PackedVector2Array
var iterations_done = 0
var offset_x
var offset_y
#endregion

func _ready():
	offset_x = -width/2
	offset_y = -height/2
	_SetFloorLayer()
	_generateNoiseGrid()
	for i in nr_of_iterations:
		_iterateGrid()

func _process(delta):
	_updateDisplay()

func _SetFloorLayer():
	tile_map.clear_layer(0)
	for x in width:
		for y in height:
			var pos = (Vector2(x+offset_x, y+offset_y))
			tile_map.set_cell(0,pos,4,Vector2(2,3))

func _generateNoiseGrid():
	noise_grid.clear()
	noise_gen._setFrequency(noise_frequency)
	for x in width:
		for y in height:
			var pos = (Vector2(x+offset_x, y+offset_y))
			var value = (noise_gen._getNoise(pos)+1)/2*100
			if value >= 100-noise_cutoff_point:
				noise_grid.append(pos)
	tile_map.clear_layer(1)
	tile_map.set_cells_terrain_connect(1,noise_grid,0,0,false)

func _iterateGrid():
	var tile
	var neighbour
	var nr_of_neighbours
	iterated_grid.clear()
	for x in width:
		for y in height:
			
			nr_of_neighbours = 0
			tile = (Vector2(x+offset_x, y+offset_y))

			neighbour = tile_map.get_neighbor_cell(tile,TileSet.CELL_NEIGHBOR_TOP_SIDE)
			if neighbour.y < offset_y\
			or tile_map.get_cell_tile_data(1,neighbour) != null:
				nr_of_neighbours += 1
			
			neighbour = tile_map.get_neighbor_cell(tile,TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER)
			if neighbour.y < offset_y\
			or neighbour.x > width + offset_x\
			or tile_map.get_cell_tile_data(1,neighbour) != null:
				nr_of_neighbours += 1
			
			neighbour = tile_map.get_neighbor_cell(tile,TileSet.CELL_NEIGHBOR_RIGHT_SIDE)
			if neighbour.x > width + offset_x\
			or tile_map.get_cell_tile_data(1,neighbour) != null:
				nr_of_neighbours += 1
			
			neighbour = tile_map.get_neighbor_cell(tile,TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER)
			if neighbour.x > width + offset_x\
			or neighbour.y > height + offset_y\
			or tile_map.get_cell_tile_data(1,neighbour) != null:
				nr_of_neighbours += 1
			
			neighbour = tile_map.get_neighbor_cell(tile,TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
			if neighbour.y > height + offset_y\
			or tile_map.get_cell_tile_data(1,neighbour) != null:
				nr_of_neighbours += 1
			
			neighbour = tile_map.get_neighbor_cell(tile,TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER)
			if neighbour.y > height + offset_y\
			or neighbour.x < offset_x\
			or tile_map.get_cell_tile_data(1,neighbour) != null:
				nr_of_neighbours += 1
			
			neighbour = tile_map.get_neighbor_cell(tile,TileSet.CELL_NEIGHBOR_LEFT_SIDE)
			if neighbour.x < offset_x\
			or tile_map.get_cell_tile_data(1,neighbour) != null:
				nr_of_neighbours += 1
			
			neighbour = tile_map.get_neighbor_cell(tile,TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER)
			if neighbour.x < offset_x\
			or neighbour.y < offset_y\
			or tile_map.get_cell_tile_data(1,neighbour) != null:
				nr_of_neighbours += 1
			
			if nr_of_neighbours >= min_nr_neighbours:
				iterated_grid.append(Vector2(tile))
	
	tile_map.clear_layer(1)
	tile_map.set_cells_terrain_connect(1,iterated_grid,0,0,false)
	iterations_done += 1

func _updateDisplay():
	iterations_display.clear()
	iterations_display.add_text("Iterations: ")
	iterations_display.add_text(str(iterations_done))
	
	width_display.clear()
	width_display.add_text("Width: ")
	width_display.add_text(str(width))
	
	height_display.clear()
	height_display.add_text("Height: ")
	height_display.add_text(str(height))
	
	tile_chance_display.clear()
	tile_chance_display.add_text("Tile Chance: ")
	tile_chance_display.add_text(str(noise_cutoff_point))
	
	neighbours_display.clear()
	neighbours_display.add_text("Neighbours >= ")
	neighbours_display.add_text(str(min_nr_neighbours))
	
	noise_freq_display.clear()
	noise_freq_display.add_text("Noise Frequency: ")
	noise_freq_display.add_text(str(noise_frequency))

func _on_regenerate_pressed():
	iterations_done = 0
	offset_x = -width/2
	offset_y = -height/2
	_SetFloorLayer()
	noise_gen._newSeed()
	_generateNoiseGrid()
	
func _on_iterate_pressed():
	_iterateGrid()

func _on_tile_chance_slider_value_changed(value):
	noise_cutoff_point = value

func _on_width_slider_value_changed(value):
	width = value

func _on_height_slider_value_changed(value):
	height = value

func _on_neighbours_slider_value_changed(value):
	min_nr_neighbours = value

func _on_noise_freq_slider_value_changed(value):
	noise_frequency = value
