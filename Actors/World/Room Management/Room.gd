# Room Resource that contains Room-related Data
# Utilized by RoomManager to track Rooms

# If a room needs to be "big", combine these rooms to form
# the big room.
class_name Room
extends Resource

enum BIGROOMGROUP {RED, GREEN, BLUE, YELLOW, NONE}

# Number of tiles that make up the room. Should be fixed 
const ROOM_LENGTH := 16
const ROOM_HEIGHT := 9

@export var roomName : String

## Room position (relative to the Map in RoomManager)
@export var gridPos : Vector2i

@export var roomScene : PackedScene

## Frees the Camera from being fixed at the centre of the room
@export var freeCameraOnEntry := false

## Group sub-rooms into one big room by a "tag". [br]
## This lousy system is mostly here to solve differentiation with adjacent big rooms
## Just make sure the same sub-rooms of a big room have the same room group
## The exact colour is arbitrary
@export var roomGroup := BIGROOMGROUP.NONE

######## Optional parameters for "safety checks" ########

## Indicates debug room, delete before production
@export var isDebug := false 
