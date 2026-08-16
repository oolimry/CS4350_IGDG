extends Node
enum ORIENTATION {NORTH, SOUTH, EAST, WEST}

const DIRECTION = { 
	ORIENTATION.WEST: Vector2.RIGHT,
	ORIENTATION.EAST: Vector2.LEFT,
	ORIENTATION.NORTH: Vector2.DOWN,
	ORIENTATION.SOUTH: Vector2.UP,
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

@export var camera : Camera2D
@export var cameraBounds : Array[Node2D]
@export var player : Player

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
	
	for boundary in boundaries:
		boundary.connect("requestChangeRoom", changeRoom)

	pass # Replace with function body.

func _physics_process(delta):
	if isCameraFollow and !shouldAnimateLerp:
		camera.global_position = player.global_position
		return

	if shouldAnimateLerp:
		camera.global_position \
			= camera.global_position.lerp(nextRoomCenterWorldCoords, delta * 5)
		if camera.global_position.is_equal_approx(nextRoomCenterWorldCoords):
			shouldAnimateLerp = false
			if isCameraFollow:
				camera.limit_enabled = true
				camera.limit_top = cameraBounds[1].global_position.y
				camera.limit_bottom = cameraBounds[0].global_position.y
				camera.limit_left = cameraBounds[1].global_position.x
				camera.limit_right = cameraBounds[0].global_position.x

func changeRoom(direction : ORIENTATION, isCameraFollow : bool):
	self.isCameraFollow = isCameraFollow
	transitioningDirection = DIRECTION.get(direction)
	nextRoomCenterWorldCoords = currRoomCenterWorldCoords + \
		transitioningDirection * roomCenterInterval
	nextRoomCoords = currRoomCoords + Vector2i(transitioningDirection)
	var nextRoom : Room = roomGrid[nextRoomCoords.x][nextRoomCoords.y] 
	
	shouldAnimateLerp = (currRoom.roomGroup != nextRoom.roomGroup) or \
		currRoom.roomGroup == Room.BIGROOMGROUP.NONE

	if isCameraFollow:
		if direction == ORIENTATION.WEST or direction == ORIENTATION.EAST:		
			camera.limit_top = cameraBounds[1].global_position.y
			camera.limit_bottom = cameraBounds[0].global_position.y
		else:
			camera.limit_left = cameraBounds[1].global_position.x
			camera.limit_right = cameraBounds[0].global_position.x
	else:
		camera.global_position = camera.get_screen_center_position()
		camera.limit_left = -INF
		camera.limit_top = -INF
		camera.limit_right = INF
		camera.limit_bottom = INF
		camera.limit_enabled = false
	
	currRoomCenterWorldCoords = nextRoomCenterWorldCoords
	currRoomCoords = nextRoomCoords
	currRoom = nextRoom
	pass
