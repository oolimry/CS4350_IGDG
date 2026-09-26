## Object-Player Collision Checker 
class_name HazardHandler
extends Node

# Changing damaged to be referenced from the tileset or enemy directly is a bit mafan ngl
## Damage dealt to player from hazards
@export var hazardDmg := 1

## Seconds of invuln after hitting hazard
@export var invulnDuration := 1.0
@export var blinkInterval := 0.1
var isInvuln := false

@export var shaderAnimator : ShaderAnimator

@export_flags_2d_physics var hazardMask: int

signal hitHazard(damage : int, isSpike : bool)
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
	if (layers & hazardMask) == 0:
		return

	# Set invuln so the player doesn't get immediately combo'd
	# to death by staying within hazard collisions
	isInvuln = true

	var collider := collision.get_collider()

	if collider is TileMapLayer:
		hitHazard.emit(hazardDmg, true)
	## otherwise damage the player normally
	else:
		hitHazard.emit(hazardDmg, false)
		collider.queue_free.call_deferred()

	# Set invuln so the player doesn't get immediately combo'd
	# to death by staying within hazard collisions
	#isInvuln = true

# This invuln func is called by Lifecycle on respawning.
# Not the best system and I greatly apologize in advance
# but I'm bussssssyyyy
func startInvulnPeriod(shouldInvuln : bool) -> void:
	if shouldInvuln:
		isInvuln = true
		await shaderAnimator.invulnFlash(blinkInterval, invulnDuration)
		isInvuln = false
	else:
		isInvuln = false
