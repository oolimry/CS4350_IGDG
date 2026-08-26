## This is a visual representation of a Room to be lay-out in the Main Game Room.
## MapLoader script will be used to load the actual room scenes from these previews
@tool
class_name RoomPreviewPlacement
extends Node2D

## The room this Preview represents 
@export var roomDefinition : RoomDefinition :
	set(roomDef):
		if roomDef == null:
			push_error("RoomDefinition is null")
		
		if roomDef.previewTexture != null:
			$Sprite2D.texture = roomDef.previewTexture
			roomDefinition = roomDef
		else:
			push_error("Please generate a preview Image for this room!")
