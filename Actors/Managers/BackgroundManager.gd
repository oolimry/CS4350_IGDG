class_name BackgroundManager
extends Node

@export var main : Node2D
@export var red : Node2D
@export var blue : Node2D
@export var purp : Node2D

var currentParallax

func _ready() -> void:
	main.visible = true
	red.visible = false
	blue.visible = false
	purp.visible = false

func swapTo(roomDef : RoomDefinition):
	if roomDef.roomArea == 0:
		main.visible = true
		red.visible = false
		blue.visible = false
		purp.visible = false
	elif roomDef.roomArea == 1:
		red.visible = true
		main.visible = false
		blue.visible = false
		purp.visible = false
	elif roomDef.roomArea == 2:
		blue.visible = true
		red.visible = false
		main.visible = false
		purp.visible = false
	elif roomDef.roomArea == 3:
		purp.visible = true
		red.visible = false
		main.visible = false
		blue.visible = false
	
