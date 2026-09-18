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
		
	swapActiveCheckPoint(c)

func onPlayerDeath(p : Player):
	p.queue_free()
	## TODO: Need to find failsafe in case player tries respawning when they have no checkpoint saved
	var newPlayer : Player = Player.create(currRespawnCheckpoint.global_position)
	playerRespawn.emit(currRespawnCheckpoint.roomPos)
	newPlayer.shaderAnimator.respawnFadeIn()
	reconnectPlayer.call(newPlayer)

func onPlayerHurt(p : Player):
	var checkpoint = currBossRespawnCheckpoint
	
	if checkpoint == null:
		checkpoint = currRespawnCheckpoint
	
	p.queue_free()
	var newPlayer : Player = Player.create(checkpoint.global_position)
	playerRespawn.emit(checkpoint.roomPos)
	newPlayer.shaderAnimator.respawnFadeIn()
	reconnectPlayer.call(newPlayer)

####################### Setup code ######################
func _registerCheckPoint(c : Node) -> void:
	if c is BossCheckPoint and c.isUniversal:
		currBossRespawnCheckpoint = c
	_registerCheckPoint(c)
