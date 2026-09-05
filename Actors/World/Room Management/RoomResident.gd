class_name RoomResident
extends RefCounted

@export var roomPos : Vector2i

## Local Coords for the object in it's Original Room
@export var oriCoords : Vector2
@export var oriRoomPos : Vector2i

@export var persistentID : StringName
@export var objectName : StringName


## Should the object always reset back to its initial state?
@export var shouldAlwaysReset : bool

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
