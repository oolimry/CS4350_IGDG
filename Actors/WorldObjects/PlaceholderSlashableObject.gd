@tool
class_name PlaceholderSlashableObject
extends StaticBody2D

@export var roomResident : RoomResident

const objName = "SlashableWall"

@export_tool_button("Generate RoomResident Data")
var generate_id_action := setup

## Should the wall continued to be destroyed after leaving the room?
@export var shouldDestructionPersist := true

func setup() -> void:
	roomResident = RoomResident.setup(objName, position, !shouldDestructionPersist)

func onSlash(slashParams : Dictionary = {}, player : Player = null):
	self.queue_free()

static func constructObjectBySnapshot(snapshot : Dictionary) -> PlaceholderSlashableObject:
	# Given how my janky code works, the RoomInstance shouldn't need to call
	# this constructor at all. The SlashableWall either exists (revert to editor-placed
	# chain) or doesn't (chain never needs to be reconstructed)
	assert(false)
	return null
	
func generateObjectSnapshot() -> Dictionary:
	var snapshot := {}
	snapshot["objectName"] = objName
	snapshot["roomResident"] = roomResident
	snapshot["localCoords"] = position
	snapshot["hasStateChanged"] = hasStateChanged()
	return snapshot

func hasStateChanged() -> bool:
	# This is okay because the state change for a slashable wall
	# is the entire deletion of said wall.
	
	# I.e. If the wall exists there has been no 
	# state change -> always return false
	return false
