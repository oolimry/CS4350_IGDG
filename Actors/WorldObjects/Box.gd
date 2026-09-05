class_name Box
extends RigidBody2D

const maxVelocity := 160.0

var roomResident : RoomResident

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	add_to_group("ContactPushable")
	roomResident = RoomResident.new()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func push(pushDirection : Vector2, pushForce : int) -> void:
	var velocity_along_push = linear_velocity.dot(pushDirection)
	
	if velocity_along_push < maxVelocity:
		apply_central_force(pushDirection * pushForce)
		
static func constructObjectBySnapshot(snapshot : Dictionary) -> Box:
	assert(snapshot["objectName"] == "Box")
	var scene := load("uid://bywkacs1kp8hb") as PackedScene
	var box := scene.instantiate() as Box
	box.linear_velocity = snapshot["linear_velocity"]
	box.sleeping = snapshot["sleeping"]
	box.position = snapshot["localCoords"]
	box.roomResident = snapshot["roomResident"]
	return box

func generateObjectSnapshot() -> Dictionary:
	var snapshot := {}
	snapshot["objectName"] = "Box"
	snapshot["roomResident"] = roomResident
	snapshot["linear_velocity"] = linear_velocity
	snapshot["sleeping"] = sleeping
	snapshot["localCoords"] = position
	return snapshot			
