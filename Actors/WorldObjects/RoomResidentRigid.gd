@tool
class_name RoomResidentRigid
extends RigidBody2D
@export var roomResident : RoomResident

@export_tool_button("Generate RoomResident Data")
var generate_id_action := setup

func setup() -> void:
	pass
	
func resync(snapshot : Dictionary) -> void:
	linear_velocity = snapshot["linear_velocity"]
	sleeping = snapshot["sleeping"]
	position = snapshot["localCoords"]
	roomResident = snapshot["roomResident"]
	freeze = snapshot["freeze"]

func generateObjectSnapshot() -> Dictionary:
	var snapshot := {}
	snapshot["roomResident"] = roomResident
	snapshot["linear_velocity"] = linear_velocity
	snapshot["sleeping"] = sleeping
	snapshot["localCoords"] = position
	snapshot["freeze"] = freeze
	snapshot["hasStateChanged"] = hasStateChanged()
	
	return snapshot
	
func hasStateChanged() -> bool:
	return roomResident.hasRoomChanged()
