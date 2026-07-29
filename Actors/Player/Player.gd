class_name Player
extends CharacterBody2D

const inf = 1e9 + 100

@onready var sprite = $Sprite2D

#x movement related
@export var xAcceleration := 82*60
@export var xDrag := 0.26

#y movement related
@export var jumpSpeed := 570
@export var jumpXBoost := 200
@export var gravity := 16
@export var fallMultiplier := 1.9
@export var breakJumpMultiplier := 1.75
@export var terminalVelocity := 500
@export var fastFallTerminalVelocity := 850
var hasBrokenJump := false

#leniency related
var timeSinceOnFloor = 0
var timeSincePressJump = 100000

var lateJumpBuffer := 0.083
var earlyJumpBuffer := 0.083

var peakHeight = 0.0

var playerXlength
var playerYlength


func _init():
	printt("TIME after Map Renderer done with _init", Time.get_ticks_msec())

func _ready():
	playerXlength = $CollisionShape2D.shape.size.x / 2.0
	playerYlength = $CollisionShape2D.shape.size.y / 2.0

func _physics_process(delta: float) -> void:	
	_physics_process_playerMovement(delta)
	
	_physics_process_updateVisuals()

func _physics_process_playerMovement(delta):
	var freezeInput = false
	
	velocity.x *= pow(1.0-xDrag, delta*60)
	if Input.is_action_pressed("left") and not freezeInput:
		velocity.x -= xAcceleration*delta
	elif Input.is_action_pressed("right") and not freezeInput:
		velocity.x += xAcceleration*delta
	else:
		velocity.x = 0

	$Sprite2D.rotation = 0
	
	if Input.is_action_just_released("jump"):
		velocity.y *= 0.75
	
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
	
	if is_on_floor():
		timeSinceOnFloor = 0
		hasBrokenJump = false
	else:
		timeSinceOnFloor += delta
		
	if is_on_floor():
		peakHeight = self.position.y
	else:
		peakHeight = min(peakHeight, self.position.y)

func _physics_process_updateVisuals():
	if velocity.x > 0 or Input.is_action_pressed("right"):
		sprite.flip_h = true
	if velocity.x < 0 or Input.is_action_pressed("left"):
		sprite.flip_h = false
		
		
