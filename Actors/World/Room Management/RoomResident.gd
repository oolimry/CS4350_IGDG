class_name RoomResident
extends Resource

#var roomPos : Vector2i

## Local Coords for the object in it's Original Room
@export var oriCoords : Vector2
@export var oriRoomPos : Vector2i

@export var persistentID : StringName
@export var objectName : StringName

## Should the object always reset back to its initial state?
@export var shouldAlwaysReset := false

var isSafeToFree := true
signal isSafeToFreeUpdate(persistentID : StringName, safety: bool)

func _init(oriCoords : Vector2, persistentID : StringName,\
 	objectName : StringName, shouldAlwaysReset := false) -> void:
		self.oriCoords = oriCoords
		
		# oriRoomPos will be filled by RoomInstance directly
		
		self.objectName = objectName
		self.persistentID = persistentID
		self.shouldAlwaysReset = shouldAlwaysReset

func toDict() -> Dictionary:
	return {
		#"roomPos_x": roomPos.x,
		#"roomPos_y": roomPos.y,
		"oriCoords_x": oriCoords.x,
		"oriCoords_y": oriCoords.y,
		"oriRoomPos_x": oriRoomPos.x,
		"oriRoomPos_y": oriRoomPos.y,
		"persistentID": persistentID,
		"shouldAlwaysReset": shouldAlwaysReset
	}

func fromDict(snapshot : Dictionary) -> void:
	#roomPos = Vector2i(snapshot["roomPos_x"],snapshot["roomPos_y"])
	oriCoords = Vector2(snapshot["oriCoords_x"], snapshot["oriCoords_y"])
	oriRoomPos = Vector2i(snapshot["oriRoomPos_x"], snapshot["oriRoomPos_y"])
	persistentID = snapshot["persistentID"]
	shouldAlwaysReset = snapshot["shouldAlwaysReset"]


static func generateUUID() -> StringName:
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
