class_name PlayerLifecycleCoordinator
extends RefCounted

var currRespawnCheckpoint : CheckPoint
var savedNormalRespawnCheckpoint : CheckPoint

var reconnectPlayer : Callable

signal playerRespawn(roomPos : Vector2i)

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
	savedNormalRespawnCheckpoint = c
	c.isActive = true

func onRespawn(isDead : bool, respawnFunc : Callable) -> void:
	respawnFunc.call(currRespawnCheckpoint.global_position)

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
			savedNormalRespawnCheckpoint = c
			currRespawnCheckpoint = c
			var newPlayer : Player = Player.create(currRespawnCheckpoint.global_position)
			reconnectPlayer.call(newPlayer)

#func handlePlayerReset(p : Player) -> Player:
	#p.queue_free()
	#var newPlayer : Player = Player.create(currRespawnCheckpoint.global_position)
	#reconnectPlayer.call(newPlayer)
	#return newPlayer
