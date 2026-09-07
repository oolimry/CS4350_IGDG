class_name PlayerLifecycleCoordinator
extends RefCounted

var currRespawnCheckpoint : CheckPoint 
var reconnectPlayer : Callable

var isSetup := true

func _init(reconnectPlayer : Callable) -> void:
	self.reconnectPlayer = reconnectPlayer
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func swapActiveCheckPoint(c : CheckPoint) -> void:
	if currRespawnCheckpoint != null:
		currRespawnCheckpoint.isActive = false
	
	currRespawnCheckpoint = c
	c.isActive = true

func onPlayerDeath(p : Player):
	p.queue_free()
	
	var newPlayer : Player = Player.create(currRespawnCheckpoint.global_position)
	newPlayer.shaderAnimator.respawnFadeIn()
	reconnectPlayer.call(newPlayer)


####################### Setup code ######################

func registerCheckPoint(rmDef : RoomDefinition, rmInst : RoomInstance) -> void:
	rmInst.forInteractables(_registerCheckPoint)

func _registerCheckPoint(c : Node) -> void:
	if c is CheckPoint:
		c.connect("checkPointReached", swapActiveCheckPoint)
		# At startup, if a checkpoint is active, spawn the player there 
		if c.isActive and isSetup:
			# This check is to ensure that only one Checkpoint is active at the
			# start of the game
			isSetup = false
			currRespawnCheckpoint = c
			var newPlayer : Player = Player.create(currRespawnCheckpoint.global_position)
			reconnectPlayer.call(newPlayer)
