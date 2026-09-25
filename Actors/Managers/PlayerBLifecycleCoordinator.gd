class_name PlayerBLifecycleCoordinator
extends PlayerLifecycleCoordinator

var currBossRespawnCheckpoint : BossCheckPoint 

func swapActiveCheckPoint(c : CheckPoint) -> void:
	if c is BossCheckPoint:
		if currBossRespawnCheckpoint != null:
			currBossRespawnCheckpoint.isActive = false
			
		currBossRespawnCheckpoint = c
		currBossRespawnCheckpoint.isActive = true
		return
		
	super.swapActiveCheckPoint(c)

func onPlayerDeath(p : Player):
	p.queue_free()
	
	if currBossRespawnCheckpoint != null:
		currBossRespawnCheckpoint.isActive = false
		currBossRespawnCheckpoint = null
	
	var newPlayer : Player = Player.create(currRespawnCheckpoint.global_position)
	playerRespawn.emit(currRespawnCheckpoint.roomPos)
	newPlayer.shaderAnimator.respawnFadeIn()
	reconnectPlayer.call(newPlayer)

func onPlayerHurt(p : Player):
	var checkpoint = currBossRespawnCheckpoint
	
	if checkpoint == null:
		checkpoint = currRespawnCheckpoint
	# Currently the Boss Respawn Checkpoint is active
	# In this case we want invulnerability
	elif p.get("hazardHandler") != null:
		p.hazardHandler.startInvulnPeriod()
		
	p.setElement(Enums.Elements.NONE)	
	
	## TODO: Need to find failsafe in case player tries respawning when they have no checkpoint saved
	
	# TODO pt2: I think this line is causing the problem but idk
	# I am in the process of transitioning from player queue free, to just moving the player back to
	# the checkpoint (so you can do like a player anim and vfx for that or sth idk)
	p.global_position = checkpoint.global_position
	
	# I tried manually setting the velocity, xAcceleration and additional velocity inputs to 0, but
	# it aint working
	
	playerRespawn.emit(checkpoint.roomPos)
	p.shaderAnimator.respawnFadeIn()
