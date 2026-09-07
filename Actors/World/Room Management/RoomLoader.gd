class_name RoomLoader
extends RefCounted

var roomInstantiator : RoomInstantiator
var mapLoader : MapLayoutLoader

func _init(mll : MapLayoutLoader, rmi : RoomInstantiator) -> void:
	roomInstantiator = rmi
	mapLoader = mll

func loadRooms(currRoomPos : Vector2i) -> void:
	mapLoader.forEachRoomDef(func(roomDef : RoomDefinition): 
		roomInstantiator.instantiateRoom(roomDef))

func unloadRooms(currRoomPos : Vector2i) -> void:
	pass

func handleRoomLoading(currRoomPos : Vector2i) -> void:
	loadRooms(currRoomPos)

	#mapLoader.forEachRoomDefBFS(func(roomDef : RoomDefinition): 
		#roomInstantiator.instantiateRoom(roomDef), currRoomPos, 1)
