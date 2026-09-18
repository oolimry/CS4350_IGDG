# GameManager class

extends Node

@export var player : Player

@export var roomManager : RoomManager

@export var persistentActors : Node2D

var playerCoordinator : PlayerLifecycleCoordinator
@export var bossManager : BossManager
var hudManager : HUDManager
var camera : GameCamera

var isSetup := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerCoordinator = PlayerLifecycleCoordinator.new(connectPlayer)
	roomManager.generateRooms(
		[playerCoordinator.registerCheckPoint, bossManager.registerBossRoom], 
	{
		"playerRespawn" : playerCoordinator.playerRespawn
	})

	pass # Replace with function body.

func connectPlayer(newPlayer : Player) -> void:
	persistentActors.add_child(newPlayer)
	player = newPlayer
	
	if !isSetup:
		setup(player)
	
	player.health.connect("death", playerCoordinator.onPlayerDeath)
	player.health.connect("hurt", func(damage : int):
		playerCoordinator.onPlayerDeath.call(player)
	)

	hudManager.connectUI(player)

# TODO: Give HUDManager as a constructor param instead
func connectBoss(boss : Boss) -> void:
	persistentActors.add_child(boss)

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
	
	player.health.connect("death", playerCoordinator.onPlayerDeath)
	
	bossManager.setup(connectBoss, hudManager, roomManager)

	
func placeAtRoot(n : Node) -> void:
	get_tree().current_scene.add_child(n)
