class_name RoomResident
extends RefCounted

var roomPos : Vector2i

## Local Coords for the object in it's Original Room
var oriCoords : Vector2
var oriRoomPos : Vector2i

var persistentID : StringName
var objectName : StringName

var isSafeToFree := true
signal isSafeToFreeUpdate(persistentID : StringName, safety: bool)

## Should the object always reset back to its initial state?
var shouldAlwaysReset := false
	
func toDict() -> Dictionary:
	return {
		"roomPos_x": roomPos.x,
		"roomPos_y": roomPos.y,
		"oriCoords_x": oriCoords.x,
		"oriCoords_y": oriCoords.y,
		"oriRoomPos_x": oriRoomPos.x,
		"oriRoomPos_y": oriRoomPos.y,
		"persistentID": persistentID,
		"shouldAlwaysReset": shouldAlwaysReset
	}

func fromDict(snapshot : Dictionary) -> void:
	roomPos = Vector2i(snapshot["roomPos_x"],snapshot["roomPos_y"])
	oriCoords = Vector2(snapshot["oriCoords_x"], snapshot["oriCoords_y"])
	oriRoomPos = Vector2i(snapshot["oriRoomPos_x"], snapshot["oriRoomPos_y"])
	persistentID = snapshot["persistentID"]
	shouldAlwaysReset = snapshot["shouldAlwaysReset"]
