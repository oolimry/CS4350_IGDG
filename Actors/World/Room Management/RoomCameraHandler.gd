class_name RoomCameraHandler
extends Node

@export var cameraCenterOffset : Vector2 = Vector2(960,540)

var isCameraFollow := false

var camera : GameCamera :
	set(c) :
		camera = c
		camera.global_position = currCameraPosition + cameraCenterOffset

var currCameraPosition : Vector2 = Vector2(0,0)

## Should the camera pan when transitioning to a new room?
var shouldAnimateLerp := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func changeRoom(currRoom : RoomDefinition, nextRoom : RoomDefinition,
	direction : Vector2i, calcRoomWorldCoords : Callable):
	 
	isCameraFollow = nextRoom.doesCameraFollow
	var nextRoomCenterWorldCoords = calcRoomWorldCoords.call(nextRoom.gridPos) + \
		cameraCenterOffset
	
	shouldAnimateLerp = (currRoom.roomGroup != nextRoom.roomGroup) or \
		currRoom.roomGroup == RoomDefinition.BIGROOMGROUP.NONE

	if isCameraFollow:
		camera.startFollowingPlayer()
		var topLeft = Vector2(nextRoomCenterWorldCoords.x - nextRoom.get_previewBounds().size[0], \
			nextRoomCenterWorldCoords.y - nextRoom.get_previewBounds().size[1])
			
		var btmRight = Vector2(nextRoomCenterWorldCoords.x + nextRoom.get_previewBounds().size[0], \
			nextRoomCenterWorldCoords.y + nextRoom.get_previewBounds().size[1])
			
		if direction == Vector2i.LEFT or direction == Vector2i.RIGHT:		
			camera.setVerticalLimit(topLeft , btmRight)
		else:
			camera.setHorizontalLimit(topLeft, btmRight)
	else:
		camera.stopFollowing()
		
	if shouldAnimateLerp:
		camera.slideTowards(nextRoomCenterWorldCoords)
	pass

func setup(gridPos : Vector2i, calcRoomCenterWorldCoords : Callable) -> void:
	currCameraPosition = calcRoomCenterWorldCoords.call(gridPos)
