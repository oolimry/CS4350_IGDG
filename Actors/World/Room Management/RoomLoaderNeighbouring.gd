class_name RoomLoaderNeighbour
extends RoomLoader

var recentlyLoadedRoomPoss : Array[Vector2i] = []

func loadRooms(currRoomPos : Vector2i) -> void:
	recentlyLoadedRoomPoss.clear()
	mapLoader.forEachRoomDefSurrounding(
		func(roomDef : RoomDefinition):
			roomInstantiator.instantiateRoom(roomDef)
			recentlyLoadedRoomPoss.append(roomDef.gridPos)\
		, currRoomPos, 2)
		
func unloadRooms(currRoomPos : Vector2i) -> void:
	var difference = roomInstantiator.loadedRooms.keys().filter(
		func(item): 
			return not recentlyLoadedRoomPoss.has(item)\
		)
	for roomPos in difference:
		roomInstantiator.freeRoom(roomPos)


func handleRoomLoading(currRoomPos : Vector2i, nextRoomPos : Vector2i) -> void:
	# TODO: This is a quick fix to snapshot restore on death
	# but there's prolly a safer way to do this
	#if currRoomPos == nextRoomPos:
		#return
		#
	roomInstantiator.snapshotRoom(currRoomPos)
	roomInstantiator.restoreSnapshot(nextRoomPos)
	loadRooms(nextRoomPos)
	unloadRooms(currRoomPos)
