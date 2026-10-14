## Object-Player Collision Checker 
class_name HazardHandler
extends Node

# Changing damaged to be referenced from the tileset or enemy directly is a bit mafan ngl
## Damage dealt to player from hazards
@export var hazardDamage := 1

## Seconds of invuln after hitting hazard

@export var shaderAnimator : ShaderAnimator

@export_flags_2d_physics var hazardMask: int

var hitHazard : Callable;
signal receiveKnockback(angle : float)

func setup(onHazard : Callable) -> void:
	hitHazard = onHazard

func actOnPotentialHazard(collision: KinematicCollision2D) -> void:

	var rid := collision.get_collider_rid()

	if not rid.is_valid():
		return

	var layers := PhysicsServer2D.body_get_collision_layer(rid)
	
	# Check if the target collider is on the "hazard" collision layer
	if (layers & hazardMask) == 0:
		return

	var collider := collision.get_collider()
		
	if collider is TileMapLayer:
		hitHazard.call(hazardDamage, true)
	## otherwise damage the player normally
	else:
		
		# Note projectiles don't follow this logic,
		# they call DamageStateHandler directly
		hitHazard.call(hazardDamage, false)
