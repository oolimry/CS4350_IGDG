class_name Box
extends RigidBody2D

const maxVelocity := 160.0

var roomResident : RoomResident

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	roomResident = RoomResident.new()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func push(pushDirection : Vector2, pushForce : int) -> void:
	var velocity_along_push = linear_velocity.dot(pushDirection)
	
	if velocity_along_push < maxVelocity:
		apply_central_force(pushDirection * pushForce)
