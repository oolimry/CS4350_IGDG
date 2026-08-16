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

## Double Array of Rooms (representing the whole map)[br]
## 0,0 is the top-left room. Note that y is First Array and x are Sub-Arrays.[br]
## If no room should be at a position, leave the entry in the array as null[br]
@export var roomGrid : Array[Array]

## The room which the player starts the game in 
@export var startRoom : Room 

## The direction in which the player is moving room to
var movDirection : Vector2
var movDest : Vector2

var isCameraFollow := false

@export var camera : Camera2D
@export var cameraBounds : Array[Node2D]
@export var player : Player

## Bunch of Placeholder variables TODO: Delete la
@export var boundaries : Array[Area2D]

var animate_lerp := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currRoom = startRoom
	currRoomCenterWorldCoords = roomCenterOffset + Vector2(currRoom.gridPos) * roomCenterInterval
	for boundary in boundaries:
		boundary.connect("requestChangeRoom", changeRoom)

	pass # Replace with function body.

func _physics_process(delta):
	if isCameraFollow:
		camera.global_position = player.global_position
		currRoomCenterWorldCoords = movDest
		return
	
	if animate_lerp:
		camera.global_position = camera.global_position.lerp(movDest, delta * 5)
		currRoomCenterWorldCoords = movDest
		if camera.global_position.is_equal_approx(movDest):
			animate_lerp = false

func changeRoom(location : ORIENTATION, isCameraFollow : bool):
	animate_lerp = true
	movDirection = DIRECTION.get(location)
	movDest = movDirection * roomCenterInterval + currRoomCenterWorldCoords
	self.isCameraFollow = isCameraFollow

	if isCameraFollow:
		camera.limit_enabled = true
		camera.limit_left = cameraBounds[1].global_position.x
		camera.limit_top = cameraBounds[1].global_position.y
		camera.limit_right = cameraBounds[0].global_position.x
		camera.limit_bottom = cameraBounds[0].global_position.y
		movDest = player.global_position
	else:
		camera.limit_enabled = false
		camera.limit_left = -INF
		camera.limit_top = -INF
		camera.limit_right = INF
		camera.limit_bottom = INF
	pass
