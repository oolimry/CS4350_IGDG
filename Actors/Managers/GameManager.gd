# GameManager class

extends Node

@export var player : Player

@export var roomManager : RoomManager

@export var persistentActors : Node2D

var playerCoordinator : PlayerLifecycleCoordinator
var hudManager : HUDManager
var camera : GameCamera

var isSetup := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerCoordinator = PlayerLifecycleCoordinator.new(connectPlayer)
	roomManager.generateRooms([playerCoordinator.spawnPlayer])
	#roomManager.getInitialPlayerInstance.connect(setup)
	
	
	## TODO: Throw this into DeathManager
	for n in get_tree().get_nodes_in_group("Checkpoint"):
		n.connect("checkPointReached", playerCoordinator.registerCheckPoint)
	pass # Replace with function body.

func connectPlayer(newPlayer : Player) -> void:
	persistentActors.add_child(newPlayer)
	player = newPlayer
	
	if !isSetup:
		setup(player)
	
	player.health.connect("playerDeath", playerCoordinator.onPlayerDeath)
	hudManager.connectUI(player)

func getPlayer() -> Player:
	return player

func setup(p : Player) -> void:
	isSetup = true
	
	# Managers that rely on the Player to work$"."
	hudManager = HUDManager.create(getPlayer)
	camera = GameCamera.create(getPlayer)
	
	get_tree().current_scene.add_child.call_deferred(hudManager)
	get_tree().current_scene.add_child.call_deferred(camera)
	
	roomManager.roomCamHandler.camera = camera
	
	player.health.connect("playerDeath", playerCoordinator.onPlayerDeath)
	
func placeAtRoot(n : Node) -> void:
	get_tree().current_scene.add_child(n)
