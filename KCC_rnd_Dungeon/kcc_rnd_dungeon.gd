extends Node2D

var room = preload("res://KCC_rnd_Dungeon/room.tscn")

@export var tile_size = 32
@export var num_rooms = 50
@export var min_size = 4
@export var max_size = 10
@export var horiz_spread = 100
@export var cull = 0.4

var path  #Astar pathfinding object

func _ready():
	randomize()
	_makeRooms()

func _makeRooms():
	for i in num_rooms: 
		var pos = Vector2(randi_range(-horiz_spread,horiz_spread),0)
		var r = room.instantiate()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.makeRoom(pos, Vector2(w,h) * tile_size)
		$Rooms.add_child(r)
	# wait for movement to stop:
	await(get_tree().create_timer(1.5).timeout)
	# cull rooms:
	var room_positions = []
	for room in $Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.set_freeze_enabled(true)
			room_positions.append(Vector2(room.position))
	await get_tree().process_frame
	# generate a Minimum Spanning Tree connecting rooms
	path = find_mst(room_positions)

func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size + room.size / 2, room.size ), Color.YELLOW, false)
	
	if path:
		for p in path.get_point_ids():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(pp,cp,Color.YELLOW, 15, true)

func _process(delta):
	queue_redraw()

func _input(event):
	if event.is_action_pressed("ui_select"):
		for n in $Rooms.get_children():
			n.queue_free()
		_makeRooms()

func find_mst(nodes):
	#Prims alghorithm
	var path = AStar2D.new()
	path.add_point(path.get_available_point_id(),nodes.pop_front())
	
	# repeat until no more nodes remain
	while nodes:
		var min_dist = INF # min distance so far
		var min_pos = null # position of that node
		var cur_pos = null # current position
		# loop through points in path
		for point1 in path.get_point_ids():
			var p1_pos = path.get_point_position(point1)
			# loop through the remaining nodes
			for point2 in nodes:
				if p1_pos.distance_to(point2) < min_dist:
					min_dist = p1_pos.distance_to(point2)
					min_pos = point2
					cur_pos = p1_pos
		var node = path.get_available_point_id()
		path.add_point(node,min_pos)
		path.connect_points(path.get_closest_point(cur_pos),node)
		nodes.erase(min_pos)
	return path
