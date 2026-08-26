extends Node2D

@onready var bomb : Bomb = $Bomb

@export var timeToLive : float = 5.0 # in seconds

func _ready():
	bomb.bringBacktoSpawn.connect(respawnBomb)
	bomb.timeLeft = timeToLive

func respawnBomb():
	remove_child(bomb)
	
	await get_tree().create_timer(1.0).timeout
	
	add_child(bomb)
	
	bomb.position = Vector2.ZERO
	bomb.timeLeft = timeToLive
	bomb.reset()
