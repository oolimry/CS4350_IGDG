class_name RoomManager
extends Node

const DIRECTION = { 
	RoomEntry.ORIENTATION.WEST: Vector2.RIGHT,
	RoomEntry.ORIENTATION.EAST: Vector2.LEFT,
	RoomEntry.ORIENTATION.NORTH: Vector2.DOWN,
	RoomEntry.ORIENTATION.SOUTH: Vector2.UP,
}

const roomCenterInterval := Vector2(1920, 1080)
const roomCenterOffset := Vector2(960, 540)

var currRoom : RoomDefinition
var currRoomCoords : Vector2i

## The direction in which the player is moving room to
var nextRoomCoords : Vector2i

@export var roomWorldCoordsOffset : Vector2

@export var mapLoader : MapLayoutLoader
@export var roomInstantiator : RoomInstantiator
@export var roomCamHandler : RoomCameraHandler

signal getInitialPlayerInstance(p : Player) 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mapLoader.forEachRoomDef(instantiateRoom)
	pass # Replace with function body.

func changeRoom(direction : RoomEntry.ORIENTATION):
	var transitioningDir : Vector2i = DIRECTION.get(direction) 
	nextRoomCoords = currRoomCoords + Vector2i(transitioningDir)
	var nextRoom : RoomDefinition = mapLoader.getRoom(nextRoomCoords)
	
	roomCamHandler.changeRoom(currRoom, nextRoom,\
		transitioningDir, calcRoomCenterWorldCoords)
		
	currRoomCoords = nextRoomCoords
	currRoom = nextRoom
	pass

func calcRoomCenterWorldCoords(roomGridPos : Vector2i) -> Vector2:
	return roomCenterOffset + \
		Vector2(roomGridPos) * roomCenterInterval

func instantiateRoom(roomDef : RoomDefinition) -> void:
	roomInstantiator.instantiateRoomWithSetup(roomDef, \
		calcRoomCenterWorldCoords, setupRoom)

func setupRoom(roomDef : RoomDefinition, sceneRootNode : Node2D) -> void:	
	var interactables : Array[Node] = \
		sceneRootNode.get_tree().get_nodes_in_group("Interactables")

	for n in interactables:
		if n is Player:
			currRoom = roomDef
			currRoomCoords = roomDef.gridPos
			roomCamHandler.setup(currRoom.gridPos, calcRoomCenterWorldCoords)

			getInitialPlayerInstance.emit(n)
		
		if n is RoomEntry:
			n.connect("requestChangeRoom", changeRoom)
	
		
