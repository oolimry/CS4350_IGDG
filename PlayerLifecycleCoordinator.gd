class_name PlayerLifecycleCoordinator
extends RefCounted

var currRespawnCheckpoint : CheckPoint 
var reconnectPlayer : Callable

func _init(reconnectPlayer : Callable) -> void:
	self.reconnectPlayer = reconnectPlayer
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func registerCheckPoint(c : CheckPoint):
	currRespawnCheckpoint = c

func onPlayerDeath(p : Player):
	p.queue_free()
	
	var newPlayer : Player = Player.create(currRespawnCheckpoint.global_position)
	newPlayer.shaderAnimator.respawnFadeIn()
	reconnectPlayer.call(newPlayer)

func spawnPlayer(r : RoomDefinition, roomInst : RoomInstance) -> void:
	if roomInst.hasPlayerSpawn:
		var newPlayer : Player = Player.create(roomInst.playerSpawnPoint.global_position)
		reconnectPlayer.call(newPlayer)
