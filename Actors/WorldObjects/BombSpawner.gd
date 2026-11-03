class_name BombSpawner
extends Node2D

var bomb : Bomb

@export var timeToLive : float = 5.0 # in seconds

var resetSignal : Signal

func _ready() -> void:
	if bomb == null:
		var bombScene : PackedScene = load("uid://bem5keqw855uo")
		bomb = bombScene.instantiate() as Bomb
	
	#bomb.bringBacktoSpawn.connect(respawnBomb)
	resetSignal.connect(bomb.attemptRespawn.bind(true).unbind(1))
	
	addBomb()

func respawnBomb(isFastRespawn := false):
	removeBomb()
	
	if not isFastRespawn:
		await get_tree().create_timer(1.0).timeout
	
	addBomb()
	
func removeBomb() -> void:
	remove_child(bomb)

func addBomb() -> void:
	get_parent().add_child.call_deferred(bomb)
	
	bomb.global_position = global_position
	bomb.timeLeft = timeToLive
	bomb.reset()

func setResetSignal(resetSignal : Signal) -> void:
	self.resetSignal = resetSignal
