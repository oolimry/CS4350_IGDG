# GameManager class

extends Node

@export var player : Player

@export var roomManager : RoomManager

@export var bgManager : BackgroundManager

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


func getPlayer() -> Player:
	return player

func setup(p : Player) -> void:
	isSetup = true
	
	# Managers that rely on the Player to work$"."
	hudManager = HUDManager.create(getPlayer)
	camera = DriftingGameCamera.create(getPlayer)
	
	get_tree().current_scene.add_child.call_deferred(hudManager)
	get_tree().current_scene.add_child.call_deferred(camera)
	
	roomManager.roomCamHandler.camera = camera
		
	bossManager.setup(placePersistentObj, hudManager, roomManager, getPlayer)
	
	roomManager.connect("playerChangedRoom", Callable(bgManager, "swapTo"))
	
func placePersistentObj(n : Node2D, child_name: StringName = "") -> Node2D:
	if child_name == "":
		persistentActors.add_child(n)
		return n
	
	var child := persistentActors.get_node_or_null(NodePath(child_name)) as Node2D
	
	if child == null:
		child = Node2D.new()
		child.name = child_name
		persistentActors.add_child(child)
		
	child.add_child(n)
	return child
	
