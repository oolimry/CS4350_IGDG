# GameManager class

extends Node

@export var player : Player

@export var roomManager : RoomManager

var deathManager : DeathManager
var hudManager : HUDManager
var camera : GameCamera

# TODO: Temporary export, would dynamically find this later
@export var checkPoints : Array[CheckPoint]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	roomManager.getInitialPlayerInstance.connect(setup)
	pass # Replace with function body.

func reconnectPlayer(newPlayer : Player) -> void:
	placeAtRoot(newPlayer)
	player = newPlayer
	
	player.health.connect("playerDeath", deathManager.onPlayerDeath)
	hudManager.connectUI(player)

func getPlayer() -> Player:
	return player

func setup(p : Player) -> void:
	player = p
	
	# Managers that rely on the Player to work$"."
	hudManager = HUDManager.create(getPlayer)
	camera = GameCamera.create(getPlayer)
	
	get_tree().current_scene.add_child.call_deferred(hudManager)
	get_tree().current_scene.add_child.call_deferred(camera)
	
	roomManager.roomCamHandler.camera = camera
	
	deathManager = DeathManager.new(reconnectPlayer)
	player.health.connect("playerDeath", deathManager.onPlayerDeath)
	
#	for cp in checkPoints:
#		cp.connect("checkPointReached", deathManager.registerCheckPoint)

func placeAtRoot(n : Node) -> void:
	get_tree().current_scene.add_child(n)
