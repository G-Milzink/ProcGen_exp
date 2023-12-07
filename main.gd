extends Node2D

var cellular_automata_01 = preload("res://cellular_automata_01/cellular_automata_01.tscn")

@onready var menu = $CanvasLayer/MarginContainer/Menu
@onready var back = $CanvasLayer/MarginContainer2/Control/Back

var instance

func _ready():
	RenderingServer.set_default_clear_color(Color("0a0613"))

func _on_back_pressed():
	if !instance == null:
		instance.queue_free()
		menu.visible = true
		back.set_text("exit")
	else:
		get_tree().quit()

func _on_cel_auto_01_pressed():
	instance = cellular_automata_01.instantiate()
	call_deferred("add_sibling", instance)
	menu.visible = false
	back.set_text("back")
