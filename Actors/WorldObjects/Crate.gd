@tool
class_name Crate
extends RoomResidentRigid

@export var attached_chain: Chain
var wasCrateOriAttached := (attached_chain != null)

const objName = "Crate"

@onready var floorCast: RayCast2D = $RayCast2D

func setup() -> void:
	roomResident = RoomResident.setup(objName, position, !wasCrateOriAttached)

func attach(chain: Chain) -> void:
	wasCrateOriAttached = true
	attached_chain = chain
	freeze = true
	
func detach() -> void:
	attached_chain = null
	freeze = false
	
func onSlash(slashParams : Dictionary = {}, player : Player = null):
	if attached_chain:
		attached_chain.attached_crate = null
		attached_chain = null

	queue_free()

func _physics_process(delta: float) -> void:
	if roomResident != null:
		roomResident.isSafeToSnapshot = floorCast.is_colliding() and (attached_chain == null)

static func constructObjectBySnapshot(snapshot : Dictionary, \
	constructHandling : Callable) -> Crate:
	assert(snapshot["objectName"] == objName)
	var scene := load("uid://dyvidqwu1eryt") as PackedScene
	var crate := scene.instantiate() as Crate
	crate.resync(snapshot)
	#crate.shouldDeleteUponDetach = snapshot["shouldDeleteUponDetach"]
	constructHandling.call(crate)
	return crate

func generateObjectSnapshot() -> Dictionary:
	var snapshot := super.generateObjectSnapshot()
	snapshot["objectName"] = objName
	#snapshot["shouldDeleteUponDetach"] = shouldDeleteUponDetach
	return snapshot

func hasStateChanged() -> bool:
	return (wasCrateOriAttached and attached_chain == null) or \
		(!wasCrateOriAttached and attached_chain != null) 
