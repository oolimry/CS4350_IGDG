class_name RoomResident
extends Resource

var currRoomPos : Vector2i

## Local Coords for the object in it's Original Room
@export var oriCoords : Vector2
@export var oriRoomPos : Vector2i

@export var persistentID : StringName
@export var objectName : StringName

## Should the object always reset back to its initial state?
@export var shouldAlwaysReset := false

var isSafeToFree := true
signal isSafeToFreeUpdate(persistentID : StringName, safety: bool)

static func setup(objName : String, position : Vector2, 
	shouldAlwaysReset := true) -> RoomResident:
	var rr = RoomResident.new()
	rr.set_local_to_scene(true)
	rr.objectName = objName
	rr.persistentID = RoomResident.generatePersistentID()
	rr.oriCoords = position
	rr.shouldAlwaysReset = shouldAlwaysReset
	return rr
	# oriRoomPos is filled later dynamically in-game from RoomInstance

func toDict() -> Dictionary:
	var dict := {
		"currRoomPos_x": currRoomPos.x,
		"currRoomPos_y": currRoomPos.y,
		"oriCoords_x": oriCoords.x,
		"oriCoords_y": oriCoords.y,
		"oriRoomPos_x": oriRoomPos.x,
		"oriRoomPos_y": oriRoomPos.y,
		"persistentID": persistentID,
		"shouldAlwaysReset": shouldAlwaysReset
	}

	return dict

func fromDict(snapshot : Dictionary) -> void:
	currRoomPos = Vector2i(snapshot["roomPos_x"],snapshot["roomPos_y"])
	oriCoords = Vector2(snapshot["oriCoords_x"], snapshot["oriCoords_y"])
	oriRoomPos = Vector2i(snapshot["oriRoomPos_x"], snapshot["oriRoomPos_y"])
	persistentID = snapshot["persistentID"]
	shouldAlwaysReset = snapshot["shouldAlwaysReset"]


static func generatePersistentID() -> StringName:
	var bytes := Crypto.new().generate_random_bytes(16)

	# UUID version 4 and RFC 4122 variant bits.
	bytes[6] = (bytes[6] & 0x0f) | 0x40
	bytes[8] = (bytes[8] & 0x3f) | 0x80

	var hex := bytes.hex_encode()
	return "%s-%s-%s-%s-%s" % [
		hex.substr(0, 8),
		hex.substr(8, 4),
		hex.substr(12, 4),
		hex.substr(16, 4),
		hex.substr(20, 12)
	]

func hasRoomChanged() -> bool:
	return currRoomPos != null and oriRoomPos != null\
		and currRoomPos != oriRoomPos
