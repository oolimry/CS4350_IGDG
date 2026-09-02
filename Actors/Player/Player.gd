class_name Player
extends CharacterBody2D

const windShockwaveHitboxTSCN = preload("res://Actors/Player/SlashHitboxes/WindShockwaveHitbox.tscn")

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
@export var jumpSpeed := 600				## vertical boost when jumping
@export var jumpXBoost := 100				## horizontal boost when jumping

@export var gravity := 22 					## the maximum downwards velocity
@export var fallMultiplier := 2.2			## when moving downwards, apply this multiplier to gravity
@export var breakJumpMultiplier := 1.8		## if player let go of jump (and still moving upwards)
@export var breakJumpDropoff := 0.70 		## when let go of jump, multiply speed by this much

@export var wallSlideTerminalVelocity := 400 ## when against wall, max fall speed
@export var terminalVelocity := 750  		## the maximum downwards velocity
@export var fastFallTerminalVelocity := 750 	## the maximum downwards velocity
var hasBrokenJump := false

## wall jump related
var isOnWall = false
var wallFacingDirection := Enums.Directions.NONE
@export var wallJumpXBoost := 750
@export var wallJumpYBoost := 650
var timeSinceNotTouchingWall = inf

var timeSinceWallJump = inf
@export var durationAfterWallJumpToHoldAwayFromWall = 0.067

#leniency related
var timeSinceOnFloor = 0
var timeSincePressJump = inf

const lateJumpBuffer := 0.090	## about 5 frames, quite lenient
const earlyJumpBuffer := 0.090	## about 5 frames, quite lenient
const lateWallJummpBuffer := 0.040 ## 2 frames, less lenient

# slashing related
@export var slashCooldown = 0.334
var timeSinceSlash = inf
var timeSincePressSlash = inf
const earlySlashBuffer := 0.120
var slashDirection : Enums.Directions = Enums.Directions.NONE

## ignition pad related
const ignitionPadHorizontalBoost = 6000
const ignitionPadVerticalLock = 240
const ignitionPadVerticalBoost = 1600


### elemental stuff
var currentElement : Enums.Elements = Enums.Elements.NONE

## wind movement related
const windHorizontalBoost = 5000
const windDownSlashBoost = 1000

## pogo related
const pogoVerticalBoost = 500

var peakHeight = 0

var freezeInput = false

var additionalVelocityInputs = []

# derived variables
var playerXlength
var playerYlength

@export var knockbackStrength := 800

## For Contact Pushing Objects -- DELETE IF NOT NEEDED --
const pushForce := 2600

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

	sprite.rotation = 0
	
	## wall shit
	isOnWall = false
	if timeSinceWallJump >= durationAfterWallJumpToHoldAwayFromWall:
		for raycast : RayCast2D in raycastsLeft:
			if raycast.is_colliding():
				timeSinceNotTouchingWall = 0.0
				wallFacingDirection = Enums.Directions.LEFT
				isOnWall = true
		for raycast : RayCast2D in raycastsRight:
			if raycast.is_colliding():
				timeSinceNotTouchingWall = 0.0
				wallFacingDirection = Enums.Directions.RIGHT
				isOnWall = true
	
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
		elif isOnWall and timeSinceNotTouchingWall < lateWallJummpBuffer:
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
	elif isWallSliding():
		if velocity.y > wallSlideTerminalVelocity:
			velocity.y = wallSlideTerminalVelocity
	else:
		if velocity.y > terminalVelocity:
			velocity.y = terminalVelocity
		
	while len(additionalVelocityInputs) > 0:
		var addedVelocity : Vector2 = additionalVelocityInputs[-1]
		velocity.x += addedVelocity.x
		if addedVelocity.y < velocity.y:
			hasBrokenJump = true
			velocity.y = addedVelocity.y
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
		
	if not(timeSinceSlash >= slashCooldown and timeSincePressSlash < earlySlashBuffer):
		return
		
	timeSincePressSlash = inf
	timeSinceSlash = 0.0
	
	slashDirection = Enums.Directions.NONE
	
	if Input.is_action_pressed("down") and not is_on_floor():
		slashDirection = Enums.Directions.DOWN
	elif Input.is_action_pressed("up"):
		slashDirection = Enums.Directions.UP
	elif Input.is_action_pressed("right"):
		slashDirection = Enums.Directions.RIGHT
	elif Input.is_action_pressed("left"):
		slashDirection = Enums.Directions.LEFT
	else:
		if sprite.flip_h:
			slashDirection = Enums.Directions.LEFT
		else:
			slashDirection = Enums.Directions.RIGHT
	
	if slashDirection == Enums.Directions.DOWN:
		downSlashHitbox.appear(self)
		sprite.play("slashDown")
	elif slashDirection == Enums.Directions.UP:
		upSlashHitbox.appear(self)
		sprite.play("slashUp")
	elif slashDirection == Enums.Directions.RIGHT:
		rightSlashHitbox.appear(self)
		sprite.play("slashSide")
	elif slashDirection == Enums.Directions.LEFT:
		leftSlashHitbox.appear(self)
		sprite.play("slashSide")
		
	if currentElement == Enums.Elements.WIND:
		var windHitbox : WindShockwaveHitbox = windShockwaveHitboxTSCN.instantiate()
		windHitbox.slashDirection = slashDirection
		windHitbox.player = self
		get_tree().root.add_child(windHitbox)
		windHitbox.global_position = self.global_position # TODO
		
		if slashDirection == Enums.Directions.DOWN:
			additionalVelocityInputs.append(Vector2(0, -windDownSlashBoost))
		elif slashDirection == Enums.Directions.UP:
			pass
		elif slashDirection == Enums.Directions.LEFT:
			additionalVelocityInputs.append(Vector2(windHorizontalBoost, 0))
		elif slashDirection == Enums.Directions.RIGHT:
			additionalVelocityInputs.append(Vector2(-windHorizontalBoost, 0))
			
		currentElement = Enums.Elements.NONE
			
	#await get_tree().create_timer(slashCooldown * 0.3).timeout
	#self.currentElement = Enums.Elements.NONE

func _physics_process_updateVisuals():
	if Input.is_action_pressed("right"):
		sprite.flip_h = false
	if Input.is_action_pressed("left"):
		sprite.flip_h = true
		
	## Elements
	if currentElement == Enums.Elements.NONE:
		sprite.material.set_shader_parameter("modulate", Color.WHITE)
	elif currentElement == Enums.Elements.WIND:
		sprite.material.set_shader_parameter("modulate", Color.PALE_TURQUOISE)
	elif currentElement == Enums.Elements.FIRE:
		sprite.material.set_shader_parameter("modulate", Color.FIREBRICK)
		
	## Animation
	var showWallSlideAnimation = isWallSliding()
	
	if sprite.is_playing() and sprite.animation in \
		["slashUp", "slashSide", "slashDown"]:
		pass
	elif is_on_floor():
		if abs(velocity.x) < 100:
			sprite.play("idle")
		else:
			sprite.play("running")
	elif showWallSlideAnimation:
		sprite.play("wallSlide")
	else:
		if velocity.y >= 0:
			sprite.play("rising")
		else:
			sprite.play("falling")
		
func checkCollisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		
		var rid := collision.get_collider_rid()

		if not rid.is_valid():
			return

		var layers := PhysicsServer2D.body_get_collision_layer(rid)
		
		var collider := collision.get_collider()

		if collider.is_in_group("ContactPushable") and collider.has_method("push"):
			var pushDirection := -collision.get_normal()
			pushDirection.y = 0
			collider.push(pushDirection, pushForce)
		
		hazardHandler.actOnPotentialHazard(collision)

func applyKnockback(normalVec : Vector2) -> void:
	additionalVelocityInputs.append(normalVec * knockbackStrength)

func pogo():
	additionalVelocityInputs.append(Vector2(0, -pogoVerticalBoost))

func launchByIgnitionPad(direction : Enums.Directions):
	if direction == Enums.Directions.RIGHT:
		additionalVelocityInputs.append(Vector2(ignitionPadHorizontalBoost, -ignitionPadVerticalLock))
	elif direction == Enums.Directions.LEFT:
		additionalVelocityInputs.append(Vector2(-ignitionPadHorizontalBoost, -ignitionPadVerticalLock))
	elif direction == Enums.Directions.UP:
		additionalVelocityInputs.append(Vector2(0, -ignitionPadVerticalBoost))

func setElement(element : Enums.Elements):
	Glogger.debug("changed element: " +  str(Enums.Elements.keys()[element]))
	
	await get_tree().create_timer(0.05).timeout
	
	currentElement = element

func isWallSliding():
	if isOnWall:
		if wallFacingDirection == Directions.LEFT and Input.is_action_pressed("left"):
			return true
		if wallFacingDirection == Directions.RIGHT and Input.is_action_pressed("right"):
			return true
	return false
