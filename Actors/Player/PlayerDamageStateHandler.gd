class_name DamageStateHandler
extends Node
# I put this here so your animation code can be separate from your movement code

# TODO: Honestly if you aint using this can delete
var shaderAnim : ShaderAnimator
@export var sprite : AnimatedSprite2D
@export var playerHealth : Health

var preRespawnFunc : Callable
var postRespawnFunc : Callable
var requestInvuln : Callable

var isHandlingDeathNow = false

@export var invulnDuration := 1.0
@export var blinkInterval := 0.1
var isInvuln := false


func setup(
	sa : ShaderAnimator, 
	handlePreRespawn : Callable, 
	handlePostRespawn : Callable
	) -> void:
		
	shaderAnim = sa
	preRespawnFunc = handlePreRespawn
	postRespawnFunc = handlePostRespawn
	pass

signal requestRespawn(isDeath : bool, respawnFunc : DamageStateHandler)


################## SPIKES #####################
# Spikes outside of Boss -> always trigger onHurt -> onSpiked only
#
# Spikes within BossRoom -> trigger onHurt -> onSpiked only
# Spikes within BossRoom kills -> trigger onDeath only
############## Other Damage ###################
# If no kill -> onHurt() only
# If kill -> onDeath() only

func onDeath() -> void:
	if isHandlingDeathNow:
		return
	isHandlingDeathNow = true
	
	await preRespawnFunc.call()

	requestRespawn.emit(true, self)
	isHandlingDeathNow =  false

func onHurt(dmg : int, isSpike : bool) -> void:
	# Do not process damage when invuln
	if isInvuln:
		return
	isInvuln = true

	if playerHealth.wouldKill(dmg):
		onDeath()
		return
	
	playerHealth.takeDamage(dmg)
	
	# IDK how your take damage animation will work
	# I'm guessing your isSpike anim should override
	# then place it here
	
	if isSpike:
		onSpiked()
		## NOTE: UNCOMMENT BELOW IF WE WANT TO SWITCH BACK
		#return
	
	startInvulnPeriod(true)

	# but jic it doesn't, place it here
	pass
	
func onSpiked() -> void:
	if isHandlingDeathNow:
		return
	
	## NOTE: UNCOMMENT BELOW IF WE WANT TO SWITCH BACK
	
	#isHandlingDeathNow = true
	
	#await preRespawnFunc.call()
	
	#requestRespawn.emit(false, self)
	#isHandlingDeathNow =  false


func postRespawnHandling(posToRespawn : Vector2, isFullHeal := true, 
	shouldStillInvuln := false) -> void:
	await get_tree().create_timer(0.01).timeout
	postRespawnFunc.call(posToRespawn)
	
	if isFullHeal:
		playerHealth.fullHeal()
	
	# wtv anim needa do
	#

	startInvulnPeriod(shouldStillInvuln)

	shaderAnim.respawnFadeIn()

func startInvulnPeriod(shouldInvuln : bool) -> void:
	if shouldInvuln:
		isInvuln = true
		await shaderAnim.invulnFlash(blinkInterval, invulnDuration)
		isInvuln = false
	else:
		isInvuln = false
