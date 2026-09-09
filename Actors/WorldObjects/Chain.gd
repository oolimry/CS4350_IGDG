@tool
class_name Chain
extends StaticBody2D

var wasCrateOriAttached := false
@export var attached_crate: Crate

@export_tool_button("Generate RoomResident Data")
var generate_id_action := setup

@export var roomResident : RoomResident

const objName = "Chain"

## Should the chain continued to be destroyed after leaving the room?
@export var shouldDestructionPersist := true
# I'm just gonna assume that the chain and crate always reset cuz
# it's 2 am demmit and I want some sleep

func setup() -> void:
	roomResident = RoomResident.setup(objName, position)

func _ready() -> void:
	if attached_crate:
		attached_crate.attach(self)
		wasCrateOriAttached = true
	roomResident.isSafeToSnapshot = attached_crate and shouldDestructionPersist
	

func onSlash(slashParams : Dictionary = {}, player : Player = null):
	if attached_crate:
		attached_crate.detach()
		attached_crate = null
		roomResident.isSafeToSnapshot = !shouldDestructionPersist
	queue_free()

static func constructObjectBySnapshot(snapshot : Dictionary,
	constructHandling : Callable) -> Chain:
	assert(snapshot["objectName"] == objName)
	var scene := load("uid://dr5hrvoct3vi0") as PackedScene
	var chain := scene.instantiate() as Chain
	chain.position = snapshot["localCoords"]
	chain.scale = snapshot["localScale"]
	chain.roomResident = snapshot["roomResident"]
	chain.shouldDestructionPersist = snapshot["shouldDestructionPersist"]
	chain.wasCrateOriAttached = snapshot["wasCrateOriAttached"]
	
	if snapshot["attachedCrate"] != null:
		chain.attached_crate = Crate.constructObjectBySnapshot(\
			snapshot["attachedCrate"], constructHandling)
	else:
		chain.attached_crate = null
	constructHandling.call(chain)
	return chain

func generateObjectSnapshot() -> Dictionary:
	var snapshot := {}
	snapshot["objectName"] = objName
	snapshot["roomResident"] = roomResident
	snapshot["localCoords"] = position
	snapshot["localScale"] = scale
	snapshot["hasStateChanged"] = hasStateChanged()
	snapshot["shouldDestructionPersist"] = shouldDestructionPersist
	snapshot["wasCrateOriAttached"] = wasCrateOriAttached

	if attached_crate != null:
		snapshot["attachedCrate"] = attached_crate.generateObjectSnapshot()
	else: 
		snapshot["attachedCrate"] = null
	return snapshot

func hasStateChanged() -> bool:
	return (wasCrateOriAttached and attached_crate == null) or \
		(!wasCrateOriAttached and attached_crate != null) #idk how this scenario occurs but eh
