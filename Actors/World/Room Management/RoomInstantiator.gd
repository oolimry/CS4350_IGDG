class_name RoomInstantiator
extends Node2D

@export var loadedRooms : Dictionary[Vector2i, RoomInstance]

@export var interactableGroupId := "Interactable" 

func instantiateRoom(roomDef : RoomDefinition, calcWorldPos : Callable) -> RoomInstance:
	var instance = roomDef.gamePlayScene.instantiate() as RoomInstance
	instance.setup(roomDef.gridPos)
	instance.global_position = calcWorldPos.call(roomDef.gridPos)
	
	for n in instance.get_children():
		if n.is_in_group(interactableGroupId) and n.has_method("getRoomPos"):
			n.roomPos = roomDef.gridPos
	
	add_child(instance)
	loadedRooms[roomDef.gridPos] = instance
	
	return instance

func instantiateRoomWithSetup(roomDef : RoomDefinition, \
	calcWorldPos : Callable, setupCallables : Array[Callable]) -> RoomInstance:
	var instance = instantiateRoom(roomDef, calcWorldPos) as RoomInstance
	
	for c in setupCallables:
		c.call(roomDef, instance)
		
	return instance

func reparentRoomResident(gameObject : Node, newRoomPos : Vector2i):
	gameObject.reparent.call_deferred(
		loadedRooms[newRoomPos].roomResidentsHolder, true)
