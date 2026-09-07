class_name RoomManager
extends Node

const roomCenterInterval := Vector2(1920, 1080)
const roomCenterOffset := Vector2(960, 540)

var currRoomPos : Vector2i

@export var roomWorldCoordsOffset : Vector2

@export var mapLoader : MapLayoutLoader
@export var roomInstantiator : RoomInstantiator
var roomLoader : RoomLoader

@export var roomCamHandler : RoomCameraHandler
var worldStateOwner : WorldStateOwner

signal getInitialPlayerInstance(p : Player) 

#var entryAreas : Array[Area2D]

################################## Setup ######################################

func _ready() -> void:
	
	pass # Replace with function body.

func generateRooms(cArray : Array[Callable]) -> void:
	worldStateOwner = WorldStateOwner.new()
	currRoomPos = mapLoader.playerSpawnRoom.gridPos
	
	cArray.append(setupRoom)
	roomInstantiator.setup(cArray, calcRoomCenterWorldCoords, worldStateOwner)
	
	roomLoader = RoomLoaderNeighbour.new(mapLoader, roomInstantiator)
	roomLoader.loadRooms(currRoomPos)
	
func setupRoom(roomDef : RoomDefinition, roomInst : RoomInstance) -> void:	
	if roomInst.roomEntry != null:
		#entryAreas.append(roomInst.roomEntry)
		roomInst.roomEntry.connect("playerChangeRoom", playerChangeRoom)
		roomInst.roomEntry.connect("objectChangeRoom", objectChangeRoom)
	else:
		push_error("Room has no Entry Collider! ", roomDef.roomName)

###################### Snapshot Related ############################################

func snapshotCurrRoom():
	var roomInstance = roomInstantiator.loadedRooms.get(currRoomPos)
	worldStateOwner.snapshotRoom(roomInstance)

func restoreCurrRoom():
	var roomInstance = roomInstantiator.loadedRooms.get(currRoomPos)
	worldStateOwner.restoreSnapshot(roomInstance)

################### RoomMovement #####################

func playerChangeRoom(roomEntry : RoomEntry, nextRoomPos : Vector2i) -> void:
	var transitioningDir : Vector2i = nextRoomPos - currRoomPos
	
	var nextRoom = mapLoader.getRoom(nextRoomPos)
	assert(nextRoom != null)
	
	roomCamHandler.changeRoom(mapLoader.getRoom(currRoomPos), \
		mapLoader.getRoom(nextRoomPos),\
		transitioningDir, calcRoomCenterWorldCoords)
		
	currRoomPos = nextRoomPos
	#
	#roomEntry.isActive = false
	#for e in entryAreas:
		#if e != roomEntry:
			#e.isActive = true
	
	roomLoader.handleRoomLoading(currRoomPos)
	
func objectChangeRoom(object : Node, nextRoomPos : Vector2i) -> void:
	# Assumption: all objects (except Player) tracked by this system have a RoomResident component 
	assert(object.roomResident != null)
	
	var roomResident : RoomResident = object.roomResident
	roomResident.roomPos = nextRoomPos
	roomInstantiator.reparentRoomResident(object, nextRoomPos)

func calcRoomCenterWorldCoords(roomGridPos : Vector2i) -> Vector2:
	return roomCenterOffset + \
		Vector2(roomGridPos) * roomCenterInterval
