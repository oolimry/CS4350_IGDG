class_name DamageStateHandler
extends RefCounted

# I know I agreed that I would put this code in Player.gd but after coding
# I realized that I really really really really really really really really
# hated scrolling through a 520+ LoC mess of dependencies just to find my func
# please forgive me and hopefully this still works for you

# I put this here so your animation code can be separate from your movement code
var sprite : AnimatedSprite2D

# TODO: Honestly if you aint using this can delete
var shaderAnim : ShaderAnimator

var playerHealth : Health
var preRespawnFunc : Callable
var postRespawnFunc : Callable
var requestInvuln : Callable
func setup(s : AnimatedSprite2D, sa : ShaderAnimator, 
	handlePreRespawn : Callable, 
	handlePostRespawn : Callable,
	handleInvuln : Callable,
	health : Health) -> void:
		
	sprite = s
	shaderAnim = sa
	preRespawnFunc = handlePreRespawn
	postRespawnFunc = handlePostRespawn
	playerHealth = health
	requestInvuln = handleInvuln
	pass

signal requestRespawn(isDeath : bool, respawnFunc : Callable)


################## SPIKES #####################
# Spikes outside of Boss -> always trigger onHurt -> onSpiked only
#
# Spikes within BossRoom -> trigger onHurt -> onSpiked only
# Spikes within BossRoom kills -> trigger onDeath only
############## Other Damage ###################
# If no kill -> onHurt() only
# If kill -> onDeath() only

func onDeath() -> void:
	preRespawnFunc.call()
	
	## Do your anim here
	
	requestRespawn.emit(true, postRespawnHandling)

func onHurt(dmg : int, isSpike : bool) -> void:
	if playerHealth.wouldKill(dmg):
		onDeath()
		return
	
	playerHealth.takeDamage(dmg)
	
	# IDK how your take damage animation will work
	# I'm guessing your isSpike anim should override
	# then place it here
	
	if isSpike:
		onSpiked()
		return
	
	requestInvuln.call(true)

	
	# but jic it doesn't, place it here
	pass
	
func onSpiked() -> void:
	preRespawnFunc.call()
	
	## Do your anim here
		
	requestRespawn.emit(false, postRespawnHandling)

func postRespawnHandling(posToRespawn : Vector2, isFullHeal := true, 
	shouldStillInvuln := false) -> void:
	
	postRespawnFunc.call(posToRespawn)
	
	if isFullHeal:
		playerHealth.fullHeal()
	
	# wtv anim needa do
	#

	requestInvuln.call(shouldStillInvuln)

	shaderAnim.respawnFadeIn()
