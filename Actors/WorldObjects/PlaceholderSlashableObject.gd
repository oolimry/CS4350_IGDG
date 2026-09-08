@tool
class_name PlaceholderSlashableObject
extends StaticBody2D

@export var roomResident : RoomResident

const objName = "SlashableWall"

@export_tool_button("Generate New ID")
var generate_id_action := generate_new_id

func generate_new_id() -> void:
	roomResident = RoomResident.new(position, 
		RoomResident.generateUUID(), objName)


func onSlash(slashParams : Dictionary = {}, player : Player = null):
	self.queue_free()

static func constructObjectBySnapshot(snapshot : Dictionary) -> PlaceholderSlashableObject:
	assert(snapshot["objectName"] == objName)
	var scene := load("uid://doqy2y3tyjoxi") as PackedScene
	var slashable := scene.instantiate() as PlaceholderSlashableObject
	slashable.position = snapshot["localCoords"]
	slashable.roomResident = snapshot["roomResident"]
	return slashable

func generateObjectSnapshot() -> Dictionary:
	var snapshot := {}
	snapshot["objectName"] = objName
	snapshot["roomResident"] = roomResident
	snapshot["localCoords"] = position
	return snapshot			
