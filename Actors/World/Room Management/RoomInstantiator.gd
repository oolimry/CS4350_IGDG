class_name RoomInstantiator
extends Node2D

@export var loadedRooms : Dictionary[Vector2i, RoomInstance]

@export var interactableGroupId := "Interactable" 

func instantiateRoom(roomDef : RoomDefinition, calcWorldPos : Callable \
	, roomCallables : Array[Callable]) -> RoomInstance:
	
	#objectCallables setup stuff like Checkpoints
	#roomCallables setup stuff that should be in the room, like the RoomEntry detection
	
	if loadedRooms.has(roomDef.gridPos):
		return loadedRooms.get(roomDef.gridPos)
	
	var instance = roomDef.gamePlayScene.instantiate() as RoomInstance
	instance.setup(roomDef.gridPos)
	instance.global_position = calcWorldPos.call(roomDef.gridPos)
	
	for n in instance.get_children():
		if n.is_in_group(interactableGroupId) and n.has_method("getRoomPos"):
			n.roomPos = roomDef.gridPos
	
	for c in roomCallables:
		c.call(roomDef, instance)
	
	add_child.call_deferred(instance)
	loadedRooms[roomDef.gridPos] = instance
	
	return instance

func reparentRoomResident(gameObject : Node, newRoomPos : Vector2i):
	gameObject.reparent.call_deferred(
		loadedRooms[newRoomPos].roomResidentsHolder, true)
