class_name ElementProjectile
extends Element

var currVelocity := Vector2(0,0)
var age := 0.0
var movementEqn : ProjectileMovementEquation

var isDestroyOnWall := false

## How many deltas should it take before we the projectile expires
var ageExpiry := 30 

static func create(elementToUse : Enums.Elements,
	movementEquation : ProjectileMovementEquation) -> ElementProjectile:
		
	var scene = load("uid://cycynpa0md52") as PackedScene
	var instance = scene.instantiate() as Element
	instance.set_script(load("uid://cg8oo17c7reiq"))
	instance = instance as ElementProjectile
	instance.element = elementToUse
	instance.movementEqn = movementEquation
	instance.collision_layer |= Enums.Layers.HAZARD
	instance.collision_mask |= Enums.Layers.PLAYER
	instance.collision_mask |= Enums.Layers.SOLID
	instance.add_to_group("Projectile", false)
	instance.body_entered.connect(instance._on_body_entered)
	return instance

func fire(initVelocity : Vector2) -> void:
	currVelocity = initVelocity
	rotation = initVelocity.angle()

func onSlash(slashParams : Dictionary = {}, player : Player = null):
	collision_shape.set_deferred("disabled", true)
	super.onSlash(slashParams, player)

func _physics_process(delta: float) -> void:
	age += delta
	global_position = movementEqn.calculateMovement(global_position, currVelocity, delta, age)
	
	if age > ageExpiry:
		queue_free.call_deferred()
		
func _on_body_entered(body : Node2D) -> void:
	if body is Player:
		body.damageStateHandler.onHurt(1, false)
		body.applyKnockback(currVelocity)
		call_deferred("queue_free")
	elif body.get_parent().get_parent() is not BossStaff and isDestroyOnWall:
		call_deferred("queue_free")

func setElementSprite(value : Enums.Elements) -> void:
	if is_instance_valid($Sprite):
		if value == Enums.Elements.WIND:
			$Sprite.play("wind-proj")
		elif value == Enums.Elements.FIRE:
			$Sprite.play("fire-proj")
		elif value == Enums.Elements.PURPLE:
			$Sprite.play("purple-proj")
