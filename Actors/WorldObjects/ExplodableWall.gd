@tool
class_name ExplodableWall
extends RoomResidentStatic

const objName = "ExplodableWall"

## Should the wall continued to be destroyed after leaving the room?
@export var shouldDestructionPersist := true

func setup() -> void:
	roomResident = RoomResident.setup(objName, position, !shouldDestructionPersist)
	
func onHitByBombExplosion():
	self.queue_free()

static func constructObjectBySnapshot(snapshot : Dictionary, \
	constructHandling : Callable) -> ExplodableWall:
	assert(snapshot["objectName"] == objName)
	var scene := load("uid://cjuxpuixfnc7s") as PackedScene
	var explodable := scene.instantiate() as ExplodableWall
	explodable.resync(snapshot)
	explodable.shouldDestructionPersist = snapshot["shouldDestructionPersist"]
	constructHandling.call(explodable)
	return explodable
	
func generateObjectSnapshot() -> Dictionary:
	var snapshot := super.generateObjectSnapshot()
	snapshot["objectName"] = objName
	snapshot["shouldDestructionPersist"] = shouldDestructionPersist
	return snapshot

func hasStateChanged() -> bool:
	# This is okay because the state change for a slashable wall
	# is the entire deletion of said wall.
	return false
