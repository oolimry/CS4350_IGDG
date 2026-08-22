@tool
class_name MapLayoutLoader
extends Node

# The first argument is the button label, the second is an optional icon name
@export var mapLayoutScene : PackedScene
@export var mapLayout : Dictionary[Vector2i, RoomDefinition]

@export_tool_button("🗺️ Generate / Map Grid Layout", "Callable")
var generate_action = _on_generate_pressed

func _on_generate_pressed() -> void:
	Glogger.debug("Generating level in editor...")
	mapLayout = generateLayout()
	
func generateLayout() -> Dictionary[Vector2i, RoomDefinition]:
	var instance = mapLayoutScene.instantiate()
	var roomLayout : Dictionary[Vector2i, RoomDefinition]
	var key := Vector2i(0,0)
	var roomDef : RoomDefinition
	for preview in instance.get_children():
		if preview is not RoomPreviewPlacement:
			pass

		roomDef = preview.roomDefinition
		key.x = preview.global_position.x / RoomDefinition.previewImageSize.x
		key.y = preview.global_position.y / RoomDefinition.previewImageSize.y
		
		if roomLayout.get(key) != null:
			push_error("Trying to load a room at the same grid coords. ", key,
				" already has ", roomLayout.find_key(key).roomName, " but trying to load"
				, roomDef.roomName)
		else:
			roomLayout[key] = roomDef
	
	return roomLayout

func getRoom(pos: Vector2i) -> RoomDefinition:
	var result : RoomDefinition = mapLayout.get(pos)
	assert(result != null)
	
	return result
