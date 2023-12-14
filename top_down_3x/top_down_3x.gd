extends Node2D

@export var width = 200
@export var height = 200

@export var noise_sand: FastNoiseLite
@export var fall_off_texture: GradientTexture2D
@export var noise_grass: FastNoiseLite
@export var noise_rock: FastNoiseLite

@onready var tile_map = $TileMap
var fall_off_image: Image
var x_offset: int
var y_offset: int

# Called when the node enters the scene tree for the first time.
func _ready():
	_prepare()
	_placeWaterTiles()
	_placeSandTiles()
	_placeGrassTiles()
	_placeRockTiles()

func _prepare():
	fall_off_texture.set_width(width)
	fall_off_texture.set_height(height)
	fall_off_image = fall_off_texture.get_image()
	x_offset = width/2
	y_offset = height/2

func _placeWaterTiles():
	for x in width:
		for y in height:
			tile_map.set_cell(0,Vector2(x-x_offset,y-y_offset),0,Vector2(5,9))

func _placeSandTiles():
	var sand_value: float
	for x in width:
		for y in height:
			sand_value = noise_sand.get_noise_2d(x,y) * fall_off_image.get_pixelv(Vector2(x,y)).r
			if sand_value > 0.0:
				tile_map.set_cells_terrain_connect(0,[Vector2(x-x_offset,y-y_offset)],0,0,true)

func _placeGrassTiles():
	var can_grow_grass: bool
	var grass_value: float
	for x in width:
		for y in height:
			can_grow_grass = tile_map.get_cell_tile_data(0,Vector2(x-x_offset,y-y_offset)).get_custom_data("can_grow_grass")
			if can_grow_grass:
				grass_value = noise_grass.get_noise_2d(x,y)
				if grass_value > -0.2:
					tile_map.set_cells_terrain_connect(1,[Vector2(x-x_offset,y-y_offset)],0,1,true)

func _placeRockTiles():
	var can_grow_grass: bool
	var rock_value: float
	for x in width:
		for y in height:
			can_grow_grass = tile_map.get_cell_tile_data(0,Vector2(x-x_offset,y-y_offset)).get_custom_data("can_grow_grass")
			if can_grow_grass:
				rock_value = noise_rock.get_noise_2d(x,y)
				if rock_value > 0.25:
					tile_map.set_cells_terrain_connect(1,[Vector2(x-x_offset,y-y_offset)],1,0,true)
