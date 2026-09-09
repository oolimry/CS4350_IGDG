@tool
class_name Box
extends RoomResidentRigid

const maxVelocity := 160.0

@export var alwaysRevert := true
static var objName := "Box"

@export var doesStateChangeConsiderCoords := false
		
func setup() -> void:
	roomResident = RoomResident.setup(objName, position, alwaysRevert)

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	add_to_group("ContactPushable")
	pass # Replace with function body.

func push(pushDirection : Vector2, pushForce : int) -> void:
	var velocity_along_push = linear_velocity.dot(pushDirection)
	
	if velocity_along_push < maxVelocity:
		apply_central_force(pushDirection * pushForce)
		
static func constructObjectBySnapshot(snapshot : Dictionary,\
	constructHandling : Callable) -> Box:
	assert(snapshot["objectName"] == objName)
	var scene := load("uid://bywkacs1kp8hb") as PackedScene
	var box := scene.instantiate() as Box
	box.resync(snapshot)
	box.alwaysRevert = snapshot["alwaysRevert"]
	box.doesStateChangeConsiderCoords = snapshot["doesStateChangeConsiderCoords"]
	constructHandling.call(box)
	return box

func generateObjectSnapshot() -> Dictionary:
	var snapshot := super.generateObjectSnapshot()
	snapshot["objectName"] = objName
	snapshot["alwaysRevert"] = alwaysRevert
	snapshot["doesStateChangeConsiderCoords"] = doesStateChangeConsiderCoords
	
	return snapshot			

func hasStateChanged() -> bool:	
	return roomResident.hasRoomChanged() or \
		(doesStateChangeConsiderCoords and !roomResident.oriCoords.is_equal_approx(position))
