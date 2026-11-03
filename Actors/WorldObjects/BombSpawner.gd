class_name BombSpawner
extends Node2D

@onready var bomb : Bomb = $Bomb

@export var timeToLive : float = 5.0 # in seconds

var resetSignal : Signal

func _ready() -> void:
	bomb.bringBacktoSpawn.connect(respawnBomb)
	resetSignal.connect(bomb.attemptRespawn.bind(true).unbind(1))

	bomb.timeLeft = timeToLive
	bomb.reset()

func respawnBomb(isFastRespawn := false) -> void:
	if not isFastRespawn:
		await get_tree().create_timer(1.0).timeout

	if not is_instance_valid(bomb) or not isSpawnAvailable():
		return

	if bomb.get_parent() != self:
		bomb.reparent(self, false)

	bomb.position = Vector2.ZERO
	bomb.timeLeft = timeToLive
	bomb.reset()

func setResetSignal(resetSignal : Signal) -> void:
	self.resetSignal = resetSignal

func isSpawnAvailable() -> bool:
	var ancestor : Node = self
	while ancestor != null:
		if ancestor.is_queued_for_deletion():
			return false
		ancestor = ancestor.get_parent()

	return is_inside_tree()
