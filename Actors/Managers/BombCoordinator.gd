class_name BombCoordinator
extends RefCounted

var onPlayerDeath : Signal

func _init(onPlayerDeath : Signal) -> void:
	self.onPlayerDeath = onPlayerDeath

func registerBombSpawner(rmDef : RoomDefinition, rmInst : RoomInstance) -> void:
	rmInst.forInteractables(_registerBombSpawner)

func _registerBombSpawner(c : Node) -> void:
	if c is BombSpawner:
		c.setResetSignal(onPlayerDeath)
		#onPlayerDeath.connect(c.bomb.attemptRespawn.bind(true).unbind(1))
