@tool
class_name Chain
extends StaticBody2D

@export var attached_crate: Crate

@export_tool_button("Generate RoomResident Data")
var generate_id_action := setup

@export var roomResident : RoomResident

const objName = "Chain"

# I'm just gonna assume that the chain and crate always reset cuz
# it's 2 am demmit and I want some sleep

func setup() -> void:
	roomResident = RoomResident.setup(objName, position)

func _ready() -> void:
	if attached_crate:
		attached_crate.attach(self)

func onSlash(slashParams : Dictionary = {}, player : Player = null):
	if attached_crate:
		attached_crate.detach()
		attached_crate = null

	queue_free()

static func constructObjectBySnapshot(snapshot : Dictionary) -> Chain:
	# Given how my janky code works, the RoomInstance shouldn't need to call
	# this constructor at all. The chain either exists (revert to editor-placed
	# chain) or doesn't (chain never needs to be reconstructed)
	assert(false)
	return null

func generateObjectSnapshot() -> Dictionary:
	var snapshot := {}
	snapshot["objectName"] = objName
	snapshot["roomResident"] = roomResident
	snapshot["localCoords"] = position
	snapshot["hasStateChanged"] = hasStateChanged()
	#snapshot["shouldDestructionPersist"] = shouldDestructionPersist
	return snapshot

func hasStateChanged() -> bool:
	# This is okay because the state change for a chain
	# is the entire deletion of said chain.
	
	# I.e. If the chain exists there has been no 
	# state change -> always return false
	return false
