class_name ElementProjectile
extends Element

@export
var initVelocity := Vector2(400, -100)

var currVelocity := Vector2(0,0)
var age := 0.0
var accelEqn : ProjAccelEqn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currVelocity = initVelocity
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	age += delta

	var acceleration := Vector2.ZERO
	if accelEqn.is_valid():
		acceleration = accelEqn.calcAcceleration(global_position, currVelocity, age)

	currVelocity += acceleration * delta
	global_position += currVelocity * delta
