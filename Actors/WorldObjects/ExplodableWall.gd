@tool
class_name ExplodableWall
extends RoomResidentStatic

const objName = "ExplodableWall"

@export var width : float = 160:
	set(value):
		width = value
		updateVisuals()
	
@export var height : float = 240:
	set(value):
		height = value
		updateVisuals()

func updateVisuals():
	if is_instance_valid($Sprite2D):
		$Sprite2D.size = Vector2(width, height) / $Sprite2D.scale.x
	if is_instance_valid($CollisionShape2D):
		$CollisionShape2D.scale = Vector2(width, height) / 100
		$CollisionShape2D.position = Vector2(width, height) * 0.5
	


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
