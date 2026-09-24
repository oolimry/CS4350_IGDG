class_name PlayerBLifecycleCoordinator
extends PlayerLifecycleCoordinator

var currBossRespawnCheckpoint : BossCheckPoint

func swapActiveCheckPoint(c : CheckPoint) -> void:
	if c is BossCheckPoint:
		if currBossRespawnCheckpoint != null:
			currBossRespawnCheckpoint.isActive = false
			
		currBossRespawnCheckpoint = c
		currBossRespawnCheckpoint.isActive
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
	
	p.setElement(Enums.Elements.NONE)	
	
	## TODO: Need to find failsafe in case player tries respawning when they have no checkpoint saved
	p.global_position = checkpoint.global_position
	playerRespawn.emit(checkpoint.roomPos)
	p.shaderAnimator.respawnFadeIn()

####################### Setup code ######################
func _registerCheckPoint(c : Node) -> void:
	if c is BossCheckPoint and c.isUniversal:
		currBossRespawnCheckpoint = c
	super._registerCheckPoint(c)
