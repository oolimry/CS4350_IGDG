class_name ElementProjectile
extends Element

var currVelocity := Vector2(0,0)
var age := 0.0
var movementEqn : ProjectileMovementEquation

## How many deltas should it take before we the projectile expires
var ageExpiry := 600 
const HAZARDMASK := 4

static func create(elementToUse : Enums.Elements,
	movementEquation : ProjectileMovementEquation) -> ElementProjectile:
		
	var scene = load("uid://cycynpa0md52") as PackedScene
	var instance = scene.instantiate() as Element
	instance.set_script(load("uid://cg8oo17c7reiq"))
	instance = instance as ElementProjectile
	instance.element = elementToUse
	instance.movementEqn = movementEquation
	instance.collision_layer |= HAZARDMASK
	return instance

func fire(initVelocity : Vector2) -> void:
	currVelocity = initVelocity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	age += delta
	global_position = movementEqn.calculateMovement(global_position, currVelocity, delta, age)
	
	if age > ageExpiry:
		queue_free.call_deferred()
		
