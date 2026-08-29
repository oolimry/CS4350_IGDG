## Object-Player Collision Checker 
class_name HazardHandler
extends Node

# Changing damaged to be referenced from the tileset or enemy directly is a bit mafan ngl
## Damage dealt to player from environment hazards
@export var hazardDamage := 2

## Seconds of invuln after hitting hazard
@export var invulnDuration := 1.0
@export var blinkInterval := 0.1
var isInvuln := false

@export var shaderAnimator : ShaderAnimator

@export_flags_2d_physics var hazard_mask: int
signal receiveDamage(damage : int)
signal receiveKnockback(angle : float)

func actOnPotentialHazard(collision: KinematicCollision2D) -> void:
	# Do not process hazards when invuln
	if isInvuln:
		return
	
	var rid := collision.get_collider_rid()

	if not rid.is_valid():
		return

	var layers := PhysicsServer2D.body_get_collision_layer(rid)
	
	# Check if the target collider is on the "hazard" collision layer
	if (layers & hazard_mask) == 0:
		return

	var collider := collision.get_collider()
	
	if !isInvuln:
		receiveDamage.emit(hazardDamage)
		receiveKnockback.emit(collision.get_normal())
		startInvulnPeriod()

func startInvulnPeriod() -> void:
	isInvuln = true
	await shaderAnimator.invulnFlash(blinkInterval, invulnDuration)
	isInvuln = false

	return
