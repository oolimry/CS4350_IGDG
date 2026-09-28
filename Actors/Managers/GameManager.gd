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
	playerCoordinator = PlayerBLifecycleCoordinator.new(connectPlayer)
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
	
	player.damageStateHandler.connect("requestRespawn", playerCoordinator.onRespawn)

	hudManager.connectUI(player)

func placePersistentObj(object : Node2D) -> void:
	persistentActors.add_child(object)

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
		
	bossManager.setup(placePersistentObj, hudManager, roomManager, getPlayer)
	
func placeAtRoot(n : Node) -> void:
	get_tree().current_scene.add_child(n)
