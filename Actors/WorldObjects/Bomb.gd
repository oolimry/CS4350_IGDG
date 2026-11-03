class_name Bomb
extends RigidBody2D

@export var collision_shape: CollisionShape2D  
@export var sprite : AnimatedSprite2D
@export var timeLabel :Label
@export var animationPlayer : AnimationPlayer
@export var explosionHitbox : Area2D

const moveDistance = 200  # pixels
const moveDuration = 0.20
var timeLeft : float = 50 # seconds
var isMovementStarted = false
var movementDirection = Vector2.ZERO
var distanceRemaining = 0

const cooldown = 0.40
var canBeMoved = true

var hasExploded = false

var isActive = false

signal bringBacktoSpawn(isFastSpawn)
var tween : Tween

func onSlash(slashParams : Dictionary = {}, player : Player = null):
	if hasExploded:
		return
	
	var element = slashParams.get(ScriptConstants.SLASH_ELEMENT_PARAM_NAME, \
		Enums.Elements.NONE)
	
	var slashDirection = slashParams.get(ScriptConstants.SLASH_DIRECTION_PARAM_NAME, \
		Enums.Directions.NONE)
		
	if element == Enums.Elements.FIRE:
		player.launchByIgnitionPadOrBomb(Enums.getOppositeDirection(slashDirection))
		explode()
		return
	
	if slashDirection == Enums.Directions.DOWN: 
		player.pogo()
	
	# prevent repeated movements
	if canBeMoved:
		isMovementStarted = true
		movementDirection = Enums.getVectorOfDirection(slashDirection)
		distanceRemaining = moveDistance
		canBeMoved = false
		
		await get_tree().create_timer(cooldown).timeout
		
		canBeMoved = true
	
func _physics_process(delta):
	# in case there's weird crate interactions w rotation
	self.rotation = 0
	
	if not isMovementStarted:
		return
	if hasExploded:
		return
		
	if distanceRemaining > 0:
		var speed = moveDistance / moveDuration
		var step = speed * delta
		var collision = move_and_collide(movementDirection * step)
		
		if collision:
			# Use actual distance traveled before the hit
			var traveled = collision.get_travel().length()
			distanceRemaining -= traveled
			
			# Reflect direction off the wall
			movementDirection = movementDirection.bounce(movementDirection * -1)
			
			# Move the remaining distance in the new direction this same frame
			move_and_collide(movementDirection * (step - traveled))
			distanceRemaining -= (step - traveled)
		else:
			distanceRemaining -= step
	
	timeLeft -= delta
	if timeLeft < 0:
		isMovementStarted = false
		attemptRespawn(false)
		return
	
	timeLabel.visible = true
	timeLabel.text = str(snappedf(timeLeft, 0.1))
	
func reset():
	animationPlayer.play("RESET")
	set_physics_process(true)
	collision_shape.set_deferred("disabled", false)
	movementDirection = Vector2.ZERO
	isMovementStarted = false
	distanceRemaining = 0
	canBeMoved = true
	timeLabel.visible = false
	hasExploded = false
	explosionHitbox.monitorable = false
	explosionHitbox.monitoring = false
	show()
	freeze = false
	isActive = true

func explode():
	explosionHitbox.monitorable = true
	explosionHitbox.monitoring = true
	hasExploded = true
	animationPlayer.play("explode")
	AudioManager.play(AudioManager.BombExploded)
	VfxManager.createVFX(VfxManager.BombExplosionVFXTSCN, \
		 self.global_position, {})
	await animationPlayer.animation_finished
	if not hasExploded:
		return
	attemptRespawn(false)

func _on_explosion_hitbox_body_entered(body : Node2D):
	if body.has_method(ScriptConstants.ON_HIT_BY_BOMB_EXPLOSION):
		body.call(ScriptConstants.ON_HIT_BY_BOMB_EXPLOSION)

func _on_explosion_hitbox_area_entered(area : Node2D):
	if area.has_method(ScriptConstants.ON_HIT_BY_BOMB_EXPLOSION):
		area.call(ScriptConstants.ON_HIT_BY_BOMB_EXPLOSION)

func attemptRespawn(isFastRespawn : bool) -> void:
	if not isActive:
		return
	isActive = false
	hide()
	freeze = true
	set_physics_process(false)
	collision_shape.set_deferred("disabled", true)
	bringBacktoSpawn.emit(isFastRespawn)	
