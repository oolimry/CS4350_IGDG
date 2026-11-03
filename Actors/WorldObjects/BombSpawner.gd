class_name BombSpawner
extends Node2D

@onready var bomb : Bomb = $Bomb

@export var timeToLive : float = 5.0 # in seconds

var resetSignal

func _init() -> void:
	if bomb == null:
		bomb = Bomb.new()
	
	bomb.bringBacktoSpawn.connect(respawnBomb)
	#resetSignal.connect(bomb.bringBacktoSpawn)
	
	bomb.timeLeft = timeToLive
	add_child(bomb)

func respawnBomb(isFastRespawn := false):
	removeBomb()
	
	if not isFastRespawn:
		await get_tree().create_timer(1.0).timeout
	
	add_child(bomb)
	
	bomb.global_position = global_position
	bomb.timeLeft = timeToLive
	bomb.reset()
	
func removeBomb() -> void:
	remove_child(bomb)

func setResetSignal(resetSignal : Signal) -> void:
	self.resetSignal = resetSignal
