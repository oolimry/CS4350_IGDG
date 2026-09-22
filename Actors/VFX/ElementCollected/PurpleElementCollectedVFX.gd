extends Node2D

@onready var particleHolder = $Particles

const burstChasingSpeed = 3500
const timeToLive = 2.0

func init(pos, params):
	global_position = pos
	
	var particles = particleHolder.get_children()
	for i in range(len(particles)):
		var particle : PurpleElementCollectedParticle = particles[i]
		var player = params[VFXManager_class.Params.PLAYER]
		
		var angle = 2*PI*i / (len(particles))
		particle.burstAndChase(player, Vector2(burstChasingSpeed, 0).rotated(angle))
	
	await get_tree().create_timer(timeToLive).timeout
	queue_free()
