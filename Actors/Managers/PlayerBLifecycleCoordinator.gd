## This class handles the special case of BossCheckpoint Respawning
## ontop of normal respawning
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

func onRespawn(isDead : bool, respawnFunc : Callable) -> void:
	# Reset BossRoom Checkpoint since the player aint respawning here again	
	if isDead and currBossRespawnCheckpoint != null:
		currBossRespawnCheckpoint.isActive = false
		currBossRespawnCheckpoint = null
		currRespawnCheckpoint = savedNormalRespawnCheckpoint
		super.onRespawn(isDead, respawnFunc)
		return

	if currBossRespawnCheckpoint == null:
		currRespawnCheckpoint = savedNormalRespawnCheckpoint
		super.onRespawn(isDead, respawnFunc)
		return
		
	respawnFunc.call(currBossRespawnCheckpoint.global_position, false, true)
