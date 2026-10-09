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

func changeRoom(currRoom : RoomDefinition, nextRoom : RoomDefinition,
	direction : Vector2i, calcRoomWorldCoords : Callable):
	 
	isCameraFollow = nextRoom.doesCameraFollow
	var nextRoomCenterWorldCoords = calcRoomWorldCoords.call(nextRoom.gridPos) + \
		cameraCenterOffset
	
	shouldAnimateLerp = currRoom.isDiffRoomGroup(nextRoom)

	var topLeft = Vector2(nextRoomCenterWorldCoords.x - nextRoom.previewBounds.size[0]/2, \
		nextRoomCenterWorldCoords.y - nextRoom.previewBounds.size[1]/2)
		
	var btmRight = Vector2(nextRoomCenterWorldCoords.x + nextRoom.previewBounds.size[0]/2, \
		nextRoomCenterWorldCoords.y + nextRoom.previewBounds.size[1]/2)
	
	#camera.setVerticalLimit(topLeft, btmRight, nextRoom)
	#camera.setHorizontalLimit(topLeft, btmRight, nextRoom)
	#if direction.sign() == Vector2i.LEFT or direction.sign() == Vector2i.RIGHT:
		#
	#else:
		
	if isCameraFollow:
		camera.startFollowingPlayer()
	else:
		camera.stopFollowing()
		
	if shouldAnimateLerp:
		camera.slideTowards(nextRoomCenterWorldCoords, 
			camera.setFullLimit.bind(topLeft, btmRight, currRoom))
	
	pass

func setup(gridPos : Vector2i, calcRoomCenterWorldCoords : Callable) -> void:
	currCameraPosition = calcRoomCenterWorldCoords.call(gridPos)
