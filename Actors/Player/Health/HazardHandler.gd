## Whenever 
class_name HazardHandler
extends Node

## Damage dealt to player from environment hazards
@export var hazardDamage := 2

## Seconds of invuln after hitting hazard
@export var playerSprite : Sprite2D
@export var invulnDuration := 1.0
@export var blinkInterval := 0.1
var isInvuln := false

@export_flags_2d_physics var hazard_mask: int
signal receiveDamage(damage : int)

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
		# TODO: Currently hazard damage is hardcoded to be 2, changing damaged to be referenced
		# from the tileset or enemy directly is a bit mafan ngl
		receiveDamage.emit(hazardDamage)
		startInvulnPeriod()

func startInvulnPeriod() -> void:
	isInvuln = true
	await invulnFlash()
	isInvuln = false

	return

# ngl, made with Gemini, thanks Gemini!
## Invlun Flash animation
func invulnFlash() -> void:
	# Strong white flash right when hit
	playerSprite.material.set_shader_parameter("flashAmount", 1.0)
	await get_tree().create_timer(0.08).timeout
	
	var elapsed := 0.0

	# Blink for the rest of the invincibility period
	while elapsed < invulnDuration:
		playerSprite.material.set_shader_parameter("flashAmount", 0.0)
		await get_tree().create_timer(blinkInterval).timeout
		elapsed += blinkInterval
		
		playerSprite.material.set_shader_parameter("flashAmount", 1.0)
		await get_tree().create_timer(blinkInterval).timeout
		elapsed += blinkInterval

	# Reset sprite
	playerSprite.material.set_shader_parameter("flashAmount", 0.0)
	pass
