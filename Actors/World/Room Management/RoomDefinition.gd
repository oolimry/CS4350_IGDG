# Room Resource that contains Room-related Data
# Utilized by RoomManager to track Rooms

# If a room needs to be "big", combine these rooms to form
# the big room.
@tool
class_name RoomDefinition
extends Resource

enum Side {
	LEFT = 1 << 0,
	RIGHT = 1 << 1,
	TOP = 1 << 2,
	BOTTOM = 1 << 3,
}

# Number of tiles that make up the room. Should be fixed 
const ROOM_LENGTH := 16
const ROOM_HEIGHT := 9

@export var roomName : String

## Whether the camera should follow the player after they enter the room
@export var doesCameraFollow : bool

@export_flags("Left", "Right", "Top", "Bottom")
var cameraLimits: int = 0

## Room position (relative to the Map in RoomManager)
@export var gridPos : Vector2i

@export var gamePlayScene : PackedScene :
	get:
		return gamePlayScene
		
static var sceneRoomSize := Vector2i(1920, 1080)

@export_flags("Left", "Right", "Top", "Bottom")
var openSides: int = 0

enum BIGROOMGROUP {RED, GREEN, BLUE, YELLOW, NONE}

## Group sub-rooms into one big room by a "tag". [br]
## This lousy system is mostly here to solve differentiation with adjacent big rooms
## Just make sure the same sub-rooms of a big room have the same room group
## The exact colour is arbitrary
@export var roomGroup := BIGROOMGROUP.NONE

######## Preview parameters for Map Layout Room Placement ########

## Preview of Room for the RoomLoader
@export var previewTexture : Texture2D

static var previewBounds := Rect2(0, 0, 1920, 1080)
		
static var previewImageSize := Vector2i(512, 288)
