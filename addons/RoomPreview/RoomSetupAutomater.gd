class_name RoomSetupAutomater
extends Node

@export var roomDef : RoomDefinition
#func setupRoom(roomScene : PackedScene, roomPos : Vector2) -> void:
	#var instance = roomScene.instantiate() as Node2D
	#add_child(instance)

func _ready() -> void:
	pass
	#setup()

func setup(grid : Dictionary[Vector2i, RoomDefinition]):
	for key in grid:
		instantiateRoom(key, grid[key])

func instantiateRoom(pos : Vector2i, r : RoomDefinition):
	var instance = r.get_gamePlayScene().instantiate() as Node2D
	add_child(instance)
 
