@tool
class_name ExplodableWall
extends RoomResidentStatic

const objName = "SlashableWall"

## Should the wall continued to be destroyed after leaving the room?
@export var shouldDestructionPersist := true

func setup() -> void:
	roomResident = RoomResident.setup(objName, position, !shouldDestructionPersist)
	
func onHitByBombExplosion():
	self.queue_free()

static func constructObjectBySnapshot(snapshot : Dictionary, \
	constructHandling : Callable) -> PlaceholderSlashableObject:
	assert(snapshot["objectName"] == objName)
	var scene := load("uid://cjuxpuixfnc7s") as PackedScene
	var slashable := scene.instantiate() as PlaceholderSlashableObject
	slashable.resync(snapshot)
	slashable.shouldDestructionPersist = snapshot["shouldDestructionPersist"]
	constructHandling.call(slashable)
	return slashable
	
func generateObjectSnapshot() -> Dictionary:
	var snapshot := super.generateObjectSnapshot()
	snapshot["objectName"] = objName
	snapshot["shouldDestructionPersist"] = shouldDestructionPersist
	return snapshot

func hasStateChanged() -> bool:
	# This is okay because the state change for a slashable wall
	# is the entire deletion of said wall.
	return false
