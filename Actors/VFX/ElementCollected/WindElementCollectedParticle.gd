class_name WindElementCollectedParticle
extends Sprite2D

@export var baseRotation = -PI / 2
@export var chasingSpeed = 3.5*60
@export var drag = 0.15
@export var delayBeforeChase = 0.35

var velocity = Vector2(0,0)
var player : Player
var timeSinceBurst = 0.0
var tangentialAcceleration = Vector2(0,0)
const tangentialAccelerationConstant = 5000

func burstAndChase(thePlayer : Player, initialVelocity : Vector2):
	velocity = initialVelocity
	player = thePlayer
	tangentialAcceleration = velocity.normalized().rotated(PI/2) * tangentialAccelerationConstant
	$Sprite2D.play("default")
	
func _process(delta):
	timeSinceBurst += delta
	
	if not is_instance_valid(player):
		queue_free()
		return	
	
	var vectorToPlayer = player.global_position - global_position
	var dist = vectorToPlayer.length()
	
	self.modulate.a = min(1.0, (dist - 40) * 0.01)
	if dist < 60 and timeSinceBurst > delayBeforeChase:
		queue_free()
	
	if timeSinceBurst < delayBeforeChase:
		velocity += tangentialAcceleration * delta
	
	velocity = velocity * (1.0 - drag)
	velocity += pow(min(1.0, timeSinceBurst/delayBeforeChase), 2) *\
		 vectorToPlayer.normalized() * chasingSpeed
	
		
		
	self.position += velocity * delta
	rotation = velocity.angle() + baseRotation
	
