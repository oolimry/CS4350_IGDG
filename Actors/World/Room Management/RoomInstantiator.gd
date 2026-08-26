class_name RoomInstantiator
extends Node2D

@export var mapLayoutLoader : MapLayoutLoader

@export var loadedRooms : Dictionary[Vector2i, Node2D]

@export var interactableGroupId := "Interactable" 

func instantiateRoom(roomDef : RoomDefinition, calcWorldPos : Callable) -> Node2D:
	var instance = roomDef.gamePlayScene.instantiate() as Node2D
	instance.global_position = calcWorldPos.call(roomDef.gridPos)
	
	for n in instance.get_children():
		if n.is_in_group(interactableGroupId) and n.has_method("getRoomPos"):
			n.roomPos = roomDef.gridPos
	
	add_child(instance)
	loadedRooms[roomDef.gridPos] = instance
	
	
	return instance

func instantiateRoomWithSetup(roomDef : RoomDefinition, \
	calcWorldPos : Callable, setupCallable : Callable) -> Node2D:
	var instance = instantiateRoom(roomDef, calcWorldPos) as Node2D
	setupCallable.call(roomDef, instance)
	return instance
