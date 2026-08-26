class_name Bomb
extends RigidBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D 
@onready var sprite : AnimatedSprite2D = $Sprite
@onready var timeLabel :Label = $Sprite/Label

const moveDistance = 200  # pixels
const moveDuration = 0.20
var timeLeft : float = 5 # seconds
var isMovementStarted = false
var movementDirection = Vector2.ZERO
var distanceRemaining = 0

const cooldown = 0.40
var canBeMoved = true

signal bringBacktoSpawn
var tween : Tween

func onSlash(slashParams : Dictionary = {}, player : Player = null):	
	var element = slashParams.get(ScriptConstants.SLASH_ELEMENT_PARAM_NAME, \
		Enums.Elements.NONE)
	
	var slashDirection = slashParams.get(ScriptConstants.SLASH_DIRECTION_PARAM_NAME, \
		Enums.Directions.NONE)
		
	if element == Enums.Elements.FIRE:
		player.launchByIgnitionPad(Enums.getOppositeDirection(slashDirection))
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
	if not isMovementStarted:
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
			movementDirection = movementDirection.bounce(collision.get_normal())
			
			# Move the remaining distance in the new direction this same frame
			move_and_collide(movementDirection * (step - traveled))
			distanceRemaining -= (step - traveled)
		else:
			distanceRemaining -= step
	
	timeLeft -= delta
	if timeLeft < 0:
		isMovementStarted = false
		bringBacktoSpawn.emit()
		return
	
	timeLabel.visible = true
	timeLabel.text = str(snappedf(timeLeft, 0.1))
	
func reset():
	movementDirection = Vector2.ZERO
	isMovementStarted = false
	timeLabel.visible = false

func explode():
	bringBacktoSpawn.emit()	
