class_name RoomLoader
extends RefCounted
 
var roomInstantiator : RoomInstantiator
var mapLoader : MapLayoutLoader

func _init(mll : MapLayoutLoader, rmi : RoomInstantiator,
	signals : Dictionary[StringName, Signal]) -> void:
	
	roomInstantiator = rmi
	mapLoader = mll
	bindSignals(signals)

func loadRooms(currRoomPos : Vector2i) -> void:
	mapLoader.forEachRoomDef(func(roomDef : RoomDefinition): 
		roomInstantiator.instantiateRoom(roomDef))

func unloadRooms(currRoomPos : Vector2i) -> void:
	pass

func handleRoomLoading(currRoomPos : Vector2i, nextRoomPos : Vector2i) -> void:
	loadRooms(currRoomPos)
	roomInstantiator.restoreSnapshot(nextRoomPos)
	#mapLoader.forEachRoomDefBFS(func(roomDef : RoomDefinition): 
		#roomInstantiator.instantiateRoom(roomDef), currRoomPos, 1)

func reloadRoom(roomPos : Vector2i) -> void:
	roomInstantiator.restoreSnapshot(roomPos)

func bindSignals(signals : Dictionary[StringName, Signal]) -> void:
	signals[&"playerRespawn"].connect(reloadRoom)	
