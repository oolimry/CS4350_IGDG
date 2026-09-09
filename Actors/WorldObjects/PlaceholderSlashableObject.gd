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

static func constructObjectBySnapshot(snapshot : Dictionary, \
	constructHandling : Callable) -> PlaceholderSlashableObject:
	assert(snapshot["objectName"] == objName)
	var scene := load("uid://doqy2y3tyjoxi") as PackedScene
	var slashable := scene.instantiate() as PlaceholderSlashableObject
	slashable.position = snapshot["localCoords"]
	slashable.scale = snapshot["localScale"]
	slashable.roomResident = snapshot["roomResident"]
	slashable.shouldDestructionPersist = snapshot["shouldDestructionPersist"]
	constructHandling.call(slashable)
	return slashable
	
func generateObjectSnapshot() -> Dictionary:
	var snapshot := {}
	snapshot["objectName"] = objName
	snapshot["roomResident"] = roomResident
	snapshot["localCoords"] = position
	snapshot["localScale"] = scale
	snapshot["hasStateChanged"] = hasStateChanged()
	snapshot["shouldDestructionPersist"] = shouldDestructionPersist
	return snapshot

func hasStateChanged() -> bool:
	# This is okay because the state change for a slashable wall
	# is the entire deletion of said wall.
	return false
