## Object-Player Collision Checker 
class_name HazardHandler
extends Node

# Changing damaged to be referenced from the tileset or enemy directly is a bit mafan ngl
## Damage dealt to player from hazards
@export var hazardDamage := 1

## Seconds of invuln after hitting hazard
@export var invulnDuration := 1.0
@export var blinkInterval := 0.1
var isInvuln := false
var isMonitoringActive := true
@export var shaderAnimator : ShaderAnimator

@export_flags_2d_physics var hazardMask: int

var hitHazard : Callable;
signal receiveKnockback(angle : float)

func setup(onHazard : Callable) -> void:
	hitHazard = onHazard

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

	var collider := collision.get_collider()
	
	isInvuln = true
	
	if collider is TileMapLayer:
		hitHazard.call(hazardDamage, true)
	## otherwise damage the player normally
	else:
		collider.queue_free()
		hitHazard.call(hazardDamage, false)
		


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
