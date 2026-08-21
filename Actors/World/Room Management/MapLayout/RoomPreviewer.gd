## This is a visual representation of a Room to be lay-out in the Main Game Room.
## MapLoader script will be used to load the actual room scenes from these previews
@tool
class_name RoomPreviwer
extends Node2D

## The room this Preview represents 
@export var roomDefinition : RoomDefinition :
	set(roomDefinition):
		$Sprite2D.texture = roomDefinition.previewTexture
