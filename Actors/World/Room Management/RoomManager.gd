class_name RoomManager
extends Node

#const DIRECTION = { 
	#RoomEntry.ORIENTATION.WEST: Vector2.RIGHT,
	#RoomEntry.ORIENTATION.EAST: Vector2.LEFT,
	#RoomEntry.ORIENTATION.NORTH: Vector2.DOWN,
	#RoomEntry.ORIENTATION.SOUTH: Vector2.UP,
#}

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

var entryAreas : Array[Area2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mapLoader.forEachRoomDef(instantiateRoom)

	pass # Replace with function body.

func changeRoom(roomEntry : RoomEntry, nextRoomPos : Vector2i):
	var transitioningDir : Vector2i = nextRoomPos - currRoom.gridPos
	
	var nextRoom = mapLoader.getRoom(nextRoomPos)
	
	roomCamHandler.changeRoom(currRoom, nextRoom,\
		transitioningDir, calcRoomCenterWorldCoords)
		
	currRoomCoords = nextRoomPos
	currRoom = nextRoom
	
	roomEntry.isActive = false
	Glogger.debug(roomEntry)
	for e in entryAreas:
		if e != roomEntry:
			Glogger.debug(e.name)
			e.isActive = true
	pass

func calcRoomCenterWorldCoords(roomGridPos : Vector2i) -> Vector2:
	return roomCenterOffset + \
		Vector2(roomGridPos) * roomCenterInterval

func instantiateRoom(roomDef : RoomDefinition) -> void:
	roomInstantiator.instantiateRoomWithSetup(roomDef, \
		calcRoomCenterWorldCoords, setupRoom)

func setupRoom(roomDef : RoomDefinition, sceneRootNode : Node2D) -> void:	
	#var interactables : Array[Node] = \
		#sceneRootNode.get_tree().get_nodes_in_group("Interactables")

	for n in sceneRootNode.get_children():
		if n is Player:
			currRoom = roomDef
			currRoomCoords = roomDef.gridPos
			roomCamHandler.setup(currRoom.gridPos, calcRoomCenterWorldCoords)

			getInitialPlayerInstance.emit(n)

		if n is RoomEntry:
			entryAreas.append(n)
			n.roomPos = roomDef.gridPos
			n.connect("requestChangeRoom", changeRoom)
