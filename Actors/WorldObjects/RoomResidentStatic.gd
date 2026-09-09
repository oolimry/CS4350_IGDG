@tool
class_name RoomResidentStatic
extends StaticBody2D
@export var roomResident : RoomResident = null

@export_tool_button("Generate RoomResident Data")
var generate_id_action := setup

func setup() -> void:
	pass
	
func resync(snapshot : Dictionary) -> void:
	scale = snapshot["localScale"]
	position = snapshot["localCoords"]
	roomResident = snapshot["roomResident"]

func generateObjectSnapshot() -> Dictionary:
	var snapshot := {}
	snapshot["roomResident"] = roomResident
	snapshot["localCoords"] = position
	snapshot["localScale"] = scale
	snapshot["hasStateChanged"] = hasStateChanged()	
	return snapshot
	
func hasStateChanged() -> bool:
	return false
