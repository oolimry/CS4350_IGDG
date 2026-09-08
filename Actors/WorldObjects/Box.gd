@tool
class_name Box
extends RigidBody2D

const maxVelocity := 160.0
@export var roomResident : RoomResident

const objName = "Box"

@export_tool_button("Generate RoomResident Data")
var generate_id_action := setup

@export var alwaysRevert := true
@export var doesStateChangeConsiderCoords := false

func setup() -> void:
	Glogger.debug("TEST")
	roomResident = RoomResident.setup(objName, position, alwaysRevert)

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	add_to_group("ContactPushable")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func push(pushDirection : Vector2, pushForce : int) -> void:
	var velocity_along_push = linear_velocity.dot(pushDirection)
	
	if velocity_along_push < maxVelocity:
		apply_central_force(pushDirection * pushForce)
		
static func constructObjectBySnapshot(snapshot : Dictionary) -> Box:
	assert(snapshot["objectName"] == objName)
	var scene := load("uid://bywkacs1kp8hb") as PackedScene
	var box := scene.instantiate() as Box
	box.linear_velocity = snapshot["linear_velocity"]
	box.sleeping = snapshot["sleeping"]
	box.position = snapshot["localCoords"]
	box.roomResident = snapshot["roomResident"]
	return box

func generateObjectSnapshot() -> Dictionary:
	var snapshot := {}
	snapshot["objectName"] = objName
	snapshot["roomResident"] = roomResident
	snapshot["linear_velocity"] = linear_velocity
	snapshot["sleeping"] = sleeping
	snapshot["localCoords"] = position
	snapshot["hasStateChanged"] = hasStateChanged()
	
	return snapshot			

func hasStateChanged() -> bool:	
	return roomResident.hasRoomChanged() or \
		(doesStateChangeConsiderCoords and roomResident.oriCoords != position)
