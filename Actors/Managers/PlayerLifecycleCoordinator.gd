class_name PlayerLifecycleCoordinator
extends RefCounted

var currRespawnCheckpoint : CheckPoint
var savedNormalRespawnCheckpoint : CheckPoint

var connectPlayer : Callable

signal playerRespawn(roomPos : Vector2i)

var isStartOfPlayer := true

func _init(connectPlayer : Callable) -> void:
	self.connectPlayer = connectPlayer
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func swapActiveCheckPoint(c : CheckPoint) -> void:
	if currRespawnCheckpoint != null:
		currRespawnCheckpoint.isActive = false
	
	currRespawnCheckpoint = c
	savedNormalRespawnCheckpoint = c
	c.isActive = true

func onRespawn(isDead : bool, dmgStateHandler : DamageStateHandler) -> void:
	dmgStateHandler.postRespawnHandling(currRespawnCheckpoint.global_position)
	playerRespawn.emit(currRespawnCheckpoint.roomPos)

####################### Setup code ######################

func registerCheckPoint(rmDef : RoomDefinition, rmInst : RoomInstance) -> void:
	rmInst.forInteractables(_registerCheckPoint)

func _registerCheckPoint(c : Node) -> void:
	if c is CheckPoint:
		c.connect("checkPointReached", swapActiveCheckPoint)
		# At startup, if a checkpoint is active, spawn the player there 
		if isStartOfPlayer:
			createPlayerOnStart(c)

func createPlayerOnStart(checkpoint : CheckPoint) -> void:
	# This check is to ensure that only one Checkpoint is active at the
	# start of the game
	isStartOfPlayer = false
	
	savedNormalRespawnCheckpoint = checkpoint
	currRespawnCheckpoint = checkpoint
	var newPlayer : Player = Player.create(currRespawnCheckpoint.global_position)
	connectPlayer.call(newPlayer)
