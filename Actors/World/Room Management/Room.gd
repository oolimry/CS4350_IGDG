# Room Resource that contains Room-related Data
# Utilized by RoomManager to track Rooms

# If a room needs to be "big", combine these rooms to form
# the big room.
class_name Room
extends Resource

# Number of tiles that make up the room. Should be fixed 
const ROOM_LENGTH := 16
const ROOM_HEIGHT := 9

@export var roomName : String

## Room position (relative to the Map in RoomManager)
@export var roomPos : Vector2i

@export var roomScene : PackedScene

## Frees the Camera from being fixed at the centre of the room
@export var freeCameraOnEntry := false

######## Optional parameters for "safety checks" ########

## Indicates debug room, delete before production
@export var isDebug := false 
