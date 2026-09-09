class_name RoomInstantiator
extends Node2D

@export var loadedRooms : Dictionary[Vector2i, RoomInstance]

@export var interactableGroupId := "Interactable"

var roomSetupCallables : Array[Callable] = []
var calcWorldPosCall : Callable = func(v : Vector2i) : return v
var worldStateOwner : WorldStateOwner = WorldStateOwner.new()

func setup(callables : Array[Callable], calcWorldPos : Callable, 
	wso : WorldStateOwner) -> void:
		
	roomSetupCallables = callables
	calcWorldPosCall = calcWorldPos
	worldStateOwner = wso

func instantiateRoom(roomDef : RoomDefinition) -> RoomInstance:
	if loadedRooms.has(roomDef.gridPos):
		return loadedRooms.get(roomDef.gridPos)
	
	var instance = roomDef.gamePlayScene.instantiate() as RoomInstance
	
	instance.roomPos = roomDef.gridPos
	
	instance.setup(roomDef.gridPos, \
		func(): worldStateOwner.restoreSnapshot(instance, true), \
		!roomDef.wasLoaded)
		
	instance.global_position = calcWorldPosCall.call(roomDef.gridPos)
	
	for n in instance.get_children():
		if n.is_in_group(interactableGroupId) and n.has_method("getRoomPos"):
			n.roomPos = roomDef.gridPos
	
	for c in roomSetupCallables:
		c.call(roomDef, instance)
	
	add_child.call_deferred(instance)
	loadedRooms[roomDef.gridPos] = instance
	
	roomDef.wasLoaded = true
	return instance

func freeRoom(roomPos : Vector2i) -> void:
	var room : RoomInstance = loadedRooms.get(roomPos)
	# TODO: Add check for whether there's something impt in the room 
	# (i.e. ongoing bomb timer)
	worldStateOwner.snapshotRoom(room)
	loadedRooms.erase(roomPos)
	room.queue_free()

func restoreSnapshot(roomPos : Vector2i) -> void:
	if loadedRooms.has(roomPos):
		worldStateOwner.restoreSnapshot(loadedRooms[roomPos], false)

func snapshotRoom(roomPos : Vector2i) -> void:
	if loadedRooms.has(roomPos):
		worldStateOwner.snapshotRoom(loadedRooms[roomPos])

func reparentRoomResident(gameObject : Node, newRoomPos : Vector2i):
	gameObject.reparent.call_deferred(
		loadedRooms[newRoomPos].roomResidentsHolder, true)
