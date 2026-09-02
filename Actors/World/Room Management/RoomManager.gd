class_name RoomManager
extends Node

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
	pass # Replace with function body.

func playerChangeRoom(roomEntry : RoomEntry, nextRoomPos : Vector2i):
	var transitioningDir : Vector2i = nextRoomPos - currRoom.gridPos
	
	var nextRoom = mapLoader.getRoom(nextRoomPos)
	
	roomCamHandler.changeRoom(currRoom, nextRoom,\
		transitioningDir, calcRoomCenterWorldCoords)
		
	currRoomCoords = nextRoomPos
	currRoom = nextRoom
	
	roomEntry.isActive = false
	for e in entryAreas:
		if e != roomEntry:
			e.isActive = true
	pass

func objectChangeRoom(object : Node, nextRoomPos : Vector2i):
	# Assumption: all objects (except Player) tracked by this system have a RoomResident component 
	assert(object.roomResident != null)
	
	var roomResident : RoomResident = object.roomResident
	roomResident.roomPos = nextRoomPos
	roomInstantiator.reparentRoomResident(object, nextRoomPos)

func calcRoomCenterWorldCoords(roomGridPos : Vector2i) -> Vector2:
	return roomCenterOffset + \
		Vector2(roomGridPos) * roomCenterInterval

func generateRooms(cArray : Array[Callable]) -> void:
	cArray.append(setupRoom)
	
	mapLoader.forEachRoomDef(func(roomDef : RoomDefinition): 
		roomInstantiator.instantiateRoomWithSetup(roomDef, \
		calcRoomCenterWorldCoords, cArray)
	)

func setupRoom(roomDef : RoomDefinition, roomInst : RoomInstance) -> void:	
	
	roomInst.roomPos = roomInst.roomPos
	
	if roomInst.roomEntry != null:
		entryAreas.append(roomInst.roomEntry)
		roomInst.roomEntry.connect("playerChangeRoom", playerChangeRoom)
		roomInst.roomEntry.connect("objectChangeRoom", objectChangeRoom)
	else:
		push_error("Room has no Entry Collider! ", roomDef.roomName)
		
	if roomInst.hasPlayerSpawn:
		assert(currRoom == null)
		currRoom = roomDef
