extends Node2D

@export var tile_size = 32
@export var num_rooms = 50
@export var min_size = 6
@export var max_size = 12
@export var horiz_spread = 800
@export var vertic_spread = 800
@export var cull = .5

var draw_generation = false

var room = preload("res://KCC_rnd_Dungeon/room.tscn")
var path  #Astar pathfinding object

@onready var tile_map = $TileMap

func _ready():
	RenderingServer.set_default_clear_color(Color("0a0613"))
	randomize()
	_makeRooms()

func _draw():
	if draw_generation:
		for i in $Rooms.get_children():
			draw_rect(Rect2(i.position - i.size + i.size / 2, i.size ), Color.YELLOW, false)
		
		if path:
			for p in path.get_point_ids():
				for c in path.get_point_connections(p):
					var pp = path.get_point_position(p)
					var cp = path.get_point_position(c)
					draw_line(pp,cp,Color.ORANGE, 15, true)

func _input(event):
	if event.is_action_pressed("ui_select"):
		for n in $Rooms.get_children():
			n.queue_free()
		_makeRooms()
	if event.is_action_pressed("ui_focus_next"):
		make_map()

func _process(delta):
	queue_redraw()

func _makeRooms():
	for i in num_rooms: 
		var pos = Vector2(randi_range(-horiz_spread,horiz_spread),randi_range(-vertic_spread,vertic_spread))
		var r = room.instantiate()
		var w = min_size + randi() % (max_size - min_size) * 2
		var h = min_size + randi() % (max_size - min_size) * 2
		r.makeRoom(pos, Vector2(w,h) * tile_size)
		$Rooms.add_child(r)
	# wait for movement to stop:
	await(get_tree().create_timer(1.5).timeout)
	# cull rooms:
	var room_positions = []
	for i in $Rooms.get_children():
		if randf() < cull:
			i.queue_free()
		else:
			i.set_freeze_enabled(true)
			room_positions.append(Vector2(i.position))
	await get_tree().process_frame
	# generate a Minimum Spanning Tree connecting rooms
	path = find_mst(room_positions)

func find_mst(nodes):
	#Prims alghorithm
	var _path = AStar2D.new()
	_path.add_point(_path.get_available_point_id(),nodes.pop_front())
	
	# repeat until no more nodes remain
	while nodes:
		var min_dist = INF # min distance so far
		var min_pos = null # position of that node
		var cur_pos = null # current position
		# loop through points in path
		for point1 in _path.get_point_ids():
			var p1_pos = _path.get_point_position(point1)
			# loop through the remaining nodes
			for point2 in nodes:
				if p1_pos.distance_to(point2) < min_dist:
					min_dist = p1_pos.distance_to(point2)
					min_pos = point2
					cur_pos = p1_pos
		var node = _path.get_available_point_id()
		_path.add_point(node,min_pos)
		_path.connect_points(_path.get_closest_point(cur_pos),node)
		nodes.erase(min_pos)
	return _path

func make_map():
	#create tilemap from generated rooms and path
	tile_map.clear()
	
	# fill tilemap with walls, then carve empty rooms
	var full_rect = Rect2()
	
	for i in $Rooms.get_children():
		var r = Rect2(i.position-i.size, i.get_node("CollisionShape2D").shape.size*2)
		full_rect = full_rect.merge(r)
	#var top_left = tile_map.local_to_map(full_rect.position)
	#var bottom_right = tile_map.local_to_map(full_rect.end)
	#for x in range(top_left.x, bottom_right.x):
		#for y in range(top_left.y, bottom_right.y):
			#tile_map.set_cell(0,Vector2(x,y), 0, Vector2(0,0))
	
	# carve rooms
	var corridors = [] # One corridor per connection
	
	for _room in $Rooms.get_children():
		var _size = (_room.size / tile_size).floor()
		var _pos = tile_map.local_to_map(_room.position)
		var _upperleft = (_room.position / tile_size).floor() - _size
		for x in range(_size.x*0.5+1, _size.x+_size.x*0.5-0.5):
			for y in range(_size.y*0.5+2, _size.y+_size.y*0.5):
				#tile_map.set_cell(0, Vector2i(_upperleft.x + x, _upperleft.y + y), 0, Vector2i(2, 2))
				tile_map.set_cells_terrain_connect(0,[Vector2i(_upperleft.x + x, _upperleft.y + y)],0,0, false)
		# carve connection
		var p = path.get_closest_point(_room.position)
		for con in path.get_point_connections(p):
			if not con in corridors:
				var start = tile_map.local_to_map(path.get_point_position(p))
				var end = tile_map.local_to_map(path.get_point_position(con))
				carve_path(start,end)
		corridors.append(p)

func carve_path(start, end):
	
	
	var difference_x = sign(end.x - start.x)
	var difference_y = sign(end.y - start.y)
	
	if difference_x == 0:
		difference_x = pow(-1.0, randi() % 2)
	if difference_y == 0:
		difference_y = pow(-1.0, randi() % 2)
		
	var x_over_y = start
	var y_over_x = end
	
	if randi() % 2 > 0:
		x_over_y = end
		y_over_x = start

	for x in range(start.x, end.x, difference_x):
		tile_map.set_cells_terrain_connect(0, [Vector2i(x, y_over_x.y)], 0, 0, false)
	for y in range(start.y, end.y, difference_y):
		tile_map.set_cells_terrain_connect(0, [Vector2i(x_over_y.x, y)], 0, 0, false)
		






