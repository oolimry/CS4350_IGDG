class_name PlayerDiedParticle
extends Sprite2D


@export var baseRotation = -PI / 2
@export var chasingSpeed = 6.5*60
@export var drag = 0.10
const tangentialAccelerationConstant = 5000

var velocity = Vector2(0,0)
var player : Player
var timeSinceBurst = 0.0
var tangentialAcceleration = Vector2(0,0)

func burstAndChase(thePlayer : Player, initialVelocity : Vector2):
	velocity = initialVelocity
	player = thePlayer
	tangentialAcceleration = velocity.normalized().rotated(PI/2) * tangentialAccelerationConstant
	
func _process(delta):
	timeSinceBurst += delta
	
	if not is_instance_valid(player):
		queue_free()
		return	
	
	var delayBeforeChase = player.deathDelay * 2.0
	
	var vectorToPlayer = player.global_position - global_position
	var dist = vectorToPlayer.length()
	
	self.modulate.a = min(1.0, (dist - 40) * 0.01)
	if dist < 60 and timeSinceBurst > delayBeforeChase * 0.5:
		queue_free()
	
	#velocity += tangentialAcceleration * delta
	
	velocity = velocity * pow(1.0 - drag, 60*delta)
	
	if not player.isDead:
		velocity += pow(min(1.0, timeSinceBurst/delayBeforeChase), 2) *\
			 vectorToPlayer.normalized() * chasingSpeed * (60*delta)
		
	self.position += velocity * delta
	rotation = velocity.angle() + baseRotation
	
