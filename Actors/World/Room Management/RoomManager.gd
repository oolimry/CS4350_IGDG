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

## The actual world coords of the current room's center
## Is some variation of: roomCenterCoords + (x * 1920, y * 1080)
var currRoomCenterWorldCoords : Vector2
var currRoom : Room
var currRoomCoords : Vector2i

## The direction in which the player is moving room to
var transitioningDirection : Vector2
var nextRoomCenterWorldCoords : Vector2
var nextRoomCoords : Vector2i

@export var roomWorldCoordsOffset : Vector2

## Double Array of Rooms (representing the whole map)[br]
## 0,0 is the top-left room. Note that y is First Array and x are Sub-Arrays.[br]
## If no room should be at a position, leave the entry in the array as null[br]
@export var roomGrid : Array[Array]

## The room which the player starts the game in 
@export var startRoom : Room 

var isCameraFollow := false

@export var camera : GameCamera
@export var cameraBounds : Array[Node2D]

@export var boundaries : Array[Area2D]

## Should the camera pan when transitioning to a new room?
var shouldAnimateLerp := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# TODO: For actual deployment, needa change this
	currRoom = startRoom
	currRoomCenterWorldCoords = roomCenterOffset + \
		Vector2(startRoom.gridPos) * roomCenterInterval - roomWorldCoordsOffset
	currRoomCoords = startRoom.gridPos
	
	camera.global_position = currRoomCenterWorldCoords
	
	for boundary in boundaries:
		boundary.connect("requestChangeRoom", changeRoom)

	pass # Replace with function body.

func changeRoom(direction : RoomEntry.ORIENTATION, isCameraFollow : bool):
	self.isCameraFollow = isCameraFollow
	transitioningDirection = DIRECTION.get(direction)
	nextRoomCenterWorldCoords = currRoomCenterWorldCoords + \
		transitioningDirection * roomCenterInterval
	nextRoomCoords = currRoomCoords + Vector2i(transitioningDirection)
	var nextRoom : Room = roomGrid[nextRoomCoords.x][nextRoomCoords.y] 
	
	shouldAnimateLerp = (currRoom.roomGroup != nextRoom.roomGroup) or \
		currRoom.roomGroup == Room.BIGROOMGROUP.NONE

	if isCameraFollow:
		camera.startFollowingPlayer()
		if direction == RoomEntry.ORIENTATION.WEST or direction == RoomEntry.ORIENTATION.EAST:		
			camera.setVerticalLimit(cameraBounds[0].global_position, cameraBounds[1].global_position)
		else:
			camera.setHorizontalLimit(cameraBounds[0].global_position, cameraBounds[1].global_position)
	else:
		camera.stopFollowing()
		
	currRoomCenterWorldCoords = nextRoomCenterWorldCoords
	currRoomCoords = nextRoomCoords
	currRoom = nextRoom
	if shouldAnimateLerp:
		camera.slideTowards(nextRoomCenterWorldCoords)
	pass
