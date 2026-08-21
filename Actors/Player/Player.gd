class_name Player
extends CharacterBody2D

const inf = 1e9 + 100

@export var health : PlayerHealth
@export var shaderAnimator : ShaderAnimator
@export var hazardHandler : HazardHandler

enum Directions {
	NONE,
	LEFT,
	RIGHT,
	UP,
	DOWN
}

@onready var sprite = $Sprite2D
@onready var leftSlashHitbox = $LeftSlashHitbox
@onready var rightSlashHitbox = $RightSlashHitbox
@onready var downSlashHitbox = $DownSlashHitbox
@onready var upSlashHitbox = $UpSlashHitbox

@onready var raycastsLeft = [$Raycasts/LeftRaycastLow, $Raycasts/LeftRaycastHigh]
@onready var raycastsRight = [$Raycasts/RightRaycastLow, $Raycasts/RightRaycastHigh]

## x movement related
@export var xAcceleration := 80*60			## how fast the character moves
@export var xDrag := 0.17					## how fast speed decays, slower = more slidy
"""
assuming 1s = 60f, i hope the code works at diff FPS

xAcceleration: in one second, how much velocity.x is increased by
xDrag: in one frame, how much does the speed decay by

This means that:	
newVelocity.x = oldVelocity.x * xDrag + xAcceleration * delta
The max running velocity is (xAcceleration / xDrag)
"""

##y movement related
@export var jumpSpeed := 670				## vertical boost when jumping
@export var jumpXBoost := 200				## horizontal boost when jumping

@export var gravity := 22 					## the maximum downwards velocity
@export var fallMultiplier := 2.2			## when moving downwards, apply this multiplier to gravity
@export var breakJumpMultiplier := 1.8		## if player let go of jump (and still moving upwards)
@export var breakJumpDropoff := 0.70 		## when let go of jump, multiply speed by this much

@export var terminalVelocity := 900  		## the maximum downwards velocity
@export var fastFallTerminalVelocity := 1350 	## the maximum downwards velocity
var hasBrokenJump := false

## wall jump related
var wallFacingDirection := Enums.Directions.NONE
@export var wallJumpXBoost := 550
@export var wallJumpYBoost := 650
var timeSinceNotTouchingWall = inf

var timeSinceWallJump = inf
@export var durationAfterWallJumpToHoldAwayFromWall = 0.067

#leniency related
var timeSinceOnFloor = 0
var timeSincePressJump = inf

const lateJumpBuffer := 0.083	## about 5 frames, quite lenient
const earlyJumpBuffer := 0.083	## about 5 frames, quite lenient

# slashing related
@export var slashCooldown = 0.3
var timeSinceSlash = inf
var timeSincePressSlash = inf
const earlySlashBuffer := 0.083

# ignition pad related
@export var ignitionPadHorizontalBoost = 5000
@export var ignitionPadVerticalBoost = 1400

var peakHeight = 0

var freezeInput = false

var additionalVelocityInputs = []

# derived variables
var playerXlength
var playerYlength

@export var knockbackStrength := 800

# Static factory function acting as a custom constructor
static func create(startingPos : Vector2) -> Player:
	## Load in HeartGUI
	var scene = load("uid://d3dqiwprm2300") as PackedScene
	var instance = scene.instantiate() as Player
	instance.global_position = startingPos
	return instance

func _init():
	printt("TIME after Map Renderer done with _init", Time.get_ticks_msec())

func _ready():
	hazardHandler.receiveDamage.connect(health.takeDamage)
	hazardHandler.receiveKnockback.connect(applyKnockback)
	
	playerXlength = $CollisionShape2D.shape.size.x / 2.0
	playerYlength = $CollisionShape2D.shape.size.y / 2.0
	
func _physics_process(delta: float) -> void:	
	_physics_process_playerMovement(delta)
	
	_physics_process_slash(delta)
		
	_physics_process_updateVisuals()
	
func _physics_process_playerMovement(delta):
	timeSinceWallJump += delta
	
	var movementDirection = Enums.Directions.NONE
	
	if timeSinceWallJump < durationAfterWallJumpToHoldAwayFromWall:
		if wallFacingDirection == Enums.Directions.LEFT:
			movementDirection = Enums.Directions.RIGHT
		elif wallFacingDirection == Enums.Directions.RIGHT:
			movementDirection = Enums.Directions.LEFT
	else:
		if Input.is_action_pressed("left") and not freezeInput:
			movementDirection = Enums.Directions.LEFT
		elif Input.is_action_pressed("right") and not freezeInput:
			movementDirection = Enums.Directions.RIGHT
	
	
	## horizontal movement
	velocity.x *= pow(1.0-xDrag, delta*60)
	if movementDirection == Enums.Directions.LEFT:
		velocity.x -= xAcceleration*delta
	elif movementDirection == Enums.Directions.RIGHT:
		velocity.x += xAcceleration*delta
	else:
		velocity.x += 0

	$Sprite2D.rotation = 0
	
	## wall shit
	if timeSinceWallJump >= durationAfterWallJumpToHoldAwayFromWall:
		for raycast : RayCast2D in raycastsLeft:
			if raycast.is_colliding():
				timeSinceNotTouchingWall = 0.0
				wallFacingDirection = Enums.Directions.LEFT
		for raycast : RayCast2D in raycastsRight:
			if raycast.is_colliding():
				timeSinceNotTouchingWall = 0.0
				wallFacingDirection = Enums.Directions.RIGHT
	
	## jumping movement
	if Input.is_action_just_released("jump"):
		velocity.y *= breakJumpDropoff
	
	if not Input.is_action_pressed("jump"):
		hasBrokenJump = true
	
	if Input.is_action_just_pressed("jump") and not freezeInput:
		timeSincePressJump = 0
		hasBrokenJump = false
		
	else:
		timeSincePressJump += delta
	
	if timeSincePressJump < earlyJumpBuffer:
		## regular jumping
		if timeSinceOnFloor < lateJumpBuffer:
			hasBrokenJump = false
			velocity.y = -jumpSpeed
			velocity.x += jumpXBoost * sign(velocity.x)
			timeSincePressJump = inf
			timeSinceOnFloor = inf
			
		## wall jumping
		elif timeSinceNotTouchingWall < lateJumpBuffer:
			hasBrokenJump = false
			timeSincePressJump = inf
			timeSinceOnFloor = inf
			timeSinceNotTouchingWall = inf
			timeSinceWallJump = 0
			velocity.y = min(velocity.y, -wallJumpYBoost)
			
			if wallFacingDirection == Enums.Directions.LEFT:
				velocity.x += wallJumpXBoost
			else:
				velocity.x -= wallJumpXBoost
	
	if velocity.y > 0:
		velocity.y += gravity * fallMultiplier * 60 * delta
	elif hasBrokenJump:
		velocity.y += gravity * breakJumpMultiplier * 60 * delta
	else:
		velocity.y += gravity * 60 * delta
	
	if Input.is_action_pressed("down") and not freezeInput:
		if velocity.y > fastFallTerminalVelocity:
			velocity.y = fastFallTerminalVelocity
	else:
		if velocity.y > terminalVelocity:
			velocity.y = terminalVelocity
		
	while len(additionalVelocityInputs) > 0:
		Glogger.debug(additionalVelocityInputs[-1])
		velocity += additionalVelocityInputs[-1]
		additionalVelocityInputs.pop_back()
	
	set_velocity(velocity)
	
	set_up_direction(Vector2.UP)
	move_and_slide()
	
	checkCollisions()
	
	if is_on_floor():
		timeSinceOnFloor = 0
		hasBrokenJump = false
	else:
		timeSinceOnFloor += delta
		
	if is_on_floor():
		peakHeight = self.position.y
	else:
		peakHeight = min(peakHeight, self.position.y)

func _physics_process_slash(delta):
	timeSinceSlash += delta
	
	if Input.is_action_just_pressed("Slash") and not freezeInput:
		timeSincePressSlash = 0
	else:
		timeSincePressSlash += delta
		
	if timeSinceSlash >= slashCooldown and timeSincePressSlash < earlySlashBuffer:
		timeSincePressSlash = inf
		timeSinceSlash = 0.0
		
		Glogger.debug("Slash")
		if Input.is_action_pressed("down") and not is_on_floor():
			downSlashHitbox.appear(self)
		elif Input.is_action_pressed("up"):
			upSlashHitbox.appear(self)
		elif Input.is_action_pressed("right"):
			Glogger.debug("RIGHT")
			rightSlashHitbox.appear(self)
		elif Input.is_action_pressed("left"):
			leftSlashHitbox.appear(self)
		else:
			if sprite.flip_h:
				rightSlashHitbox.appear(self)
			else:
				leftSlashHitbox.appear(self)

func _physics_process_updateVisuals():
	if Input.is_action_pressed("right"):
		sprite.flip_h = true
	if Input.is_action_pressed("left"):
		sprite.flip_h = false	
		
func checkCollisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		hazardHandler.actOnPotentialHazard(collision)

func applyKnockback(normalVec : Vector2) -> void:
	additionalVelocityInputs.append(normalVec * knockbackStrength)

func launchByIgnitionPad(direction : Enums.Directions):
	if direction == Enums.Directions.RIGHT:
		additionalVelocityInputs.append(Vector2(ignitionPadHorizontalBoost, 0))
	elif direction == Enums.Directions.LEFT:
		additionalVelocityInputs.append(Vector2(-ignitionPadHorizontalBoost, 0))
	elif direction == Enums.Directions.UP:
		additionalVelocityInputs.append(Vector2(0, -ignitionPadVerticalBoost))
