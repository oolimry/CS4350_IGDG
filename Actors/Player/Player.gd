class_name Player
extends CharacterBody2D

const inf = 1e9 + 100

@export var health : PlayerHealth
@export var painProcessor : PainProcessor

@onready var sprite = $Sprite2D
@onready var sideSlashHitbox = $SideSlashHitbox

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

@export var gravity := 20 					## the maximum downwards velocity
@export var fallMultiplier := 2.1			## when moving downwards, apply this multiplier to gravity
@export var breakJumpMultiplier := 1.75		## if player let go of jump (and still moving upwards)
@export var breakJumpDropoff := 0.70 		## when let go of jump, multiply speed by this much

@export var terminalVelocity := 900  		## the maximum downwards velocity
@export var fastFallTerminalVelocity := 1350 	## the maximum downwards velocity
var hasBrokenJump := false

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

var peakHeight = 0

var freezeInput = false
	
# derived variables
var sideSlashHitboxOffset = 93
var playerXlength
var playerYlength

func _init():
	printt("TIME after Map Renderer done with _init", Time.get_ticks_msec())

func _ready():
	painProcessor.receiveDamage.connect(health.takeDamage)
	playerXlength = $CollisionShape2D.shape.size.x / 2.0
	playerYlength = $CollisionShape2D.shape.size.y / 2.0
	
	sideSlashHitboxOffset = abs(sideSlashHitbox.position.x)

func _physics_process(delta: float) -> void:	
	_physics_process_playerMovement(delta)
	
	_physics_process_slash(delta)
		
	_physics_process_updateVisuals()
	
	
func _physics_process_playerMovement(delta):	
	
	velocity.x *= pow(1.0-xDrag, delta*60)
	if Input.is_action_pressed("left") and not freezeInput:
		velocity.x -= xAcceleration*delta
	elif Input.is_action_pressed("right") and not freezeInput:
		velocity.x += xAcceleration*delta
	else:
		velocity.x = 0

	$Sprite2D.rotation = 0
	
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
		#regular jumping
		if timeSinceOnFloor < lateJumpBuffer:
			hasBrokenJump = false
			velocity.y = -jumpSpeed
			velocity.x += jumpXBoost * sign(velocity.x)
			timeSincePressJump = inf
			timeSinceOnFloor = inf
	
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
	
	if Input.is_action_pressed("Slash") and not freezeInput:
		timeSincePressSlash = 0
	else:
		timeSincePressSlash += delta
		
	if timeSinceSlash >= slashCooldown and timeSincePressSlash < earlySlashBuffer:
		timeSincePressSlash = inf
		timeSinceSlash = 0.0
		sideSlashHitbox.appear()

func _physics_process_updateVisuals():
	if velocity.x > 0 or Input.is_action_pressed("right"):
		sprite.flip_h = true
		sideSlashHitbox.position.x = sideSlashHitboxOffset
		sideSlashHitbox.scale.x = 1
	if velocity.x < 0 or Input.is_action_pressed("left"):
		sprite.flip_h = false
		sideSlashHitbox.position.x = -sideSlashHitboxOffset
		sideSlashHitbox.scale.x = -1
		
		
func checkCollisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		painProcessor.actOnPotentialHazard(collision)
#		
		#if isHazard(collision):
			#body.take_damage(1)
