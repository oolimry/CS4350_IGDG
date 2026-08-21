# Room Resource that contains Room-related Data
# Utilized by RoomManager to track Rooms

# If a room needs to be "big", combine these rooms to form
# the big room.
class_name RoomDefinition
extends Resource

# Number of tiles that make up the room. Should be fixed 
const ROOM_LENGTH := 16
const ROOM_HEIGHT := 9

@export var roomName : String

## Room position (relative to the Map in RoomManager)
@export var gridPos : Vector2i

@export var gamePlayScene : PackedScene

## Dimension of room by RUs
@export var roomSize : Vector2i

######## Optional parameters for "safety checks" ########

## Preview of Room for the RoomLoader
@export var previewTexture : Texture2D
@export var previewBounds := Rect2(0, 0, 1920, 1080)
@export var previewImageSize := Vector2i(512, 288)

## Frees the Camera from being fixed at the centre of the room
@export var freeCameraOnEntry := false

######## Optional parameters for "safety checks" ########

## Indicates debug room, delete before production
@export var isDebug := false 
