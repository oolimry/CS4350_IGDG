@tool
class_name MapLayoutLoader
extends Node

@export var mapLayoutScene : PackedScene
@export var mapLayout : Dictionary[Vector2i, RoomDefinition]

@export var playerSpawnRoom : RoomDefinition


# The first argument is the button label, the second is an optional icon name
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
			roomDef.gridPos = key
	
		if roomDef.hasPlayer:
			push_error("We have multiple Players! :O")
			assert(playerSpawnRoom == null)
			playerSpawnRoom = roomDef
	
	instance.queue_free()
	assert(playerSpawnRoom != null)
	return roomLayout

func getRoom(pos: Vector2i) -> RoomDefinition:
	var result : RoomDefinition = mapLayout.get(pos)
	if result == null:
		push_error("Room does not exist!")
		push_error(pos)
	
	return result
	
func forEachRoomDef(c : Callable) -> void:
	for r in mapLayout.values():
		c.call(r)
		
func forEachRoomDefSurrounding(c : Callable, pos: Vector2i, depth := 1) -> void:
	var roomDef : RoomDefinition = getRoom(pos)
	if roomDef == null:
		return;
	
	c.call(roomDef)
	
	if depth == 0:
		return
	var newDepth = depth - 1
	
	if roomDef.openSides & RoomDefinition.Side.LEFT:
		forEachRoomDefSurrounding(c, pos - Vector2i(1,0), newDepth)
		
	if roomDef.openSides & RoomDefinition.Side.RIGHT:
		forEachRoomDefSurrounding(c, pos + Vector2i(1,0), newDepth)
		
	if roomDef.openSides & RoomDefinition.Side.TOP:
		forEachRoomDefSurrounding(c, pos - Vector2i(0,1), newDepth)

	if roomDef.openSides & RoomDefinition.Side.BOTTOM:
		forEachRoomDefSurrounding(c, pos + Vector2i(0,1), newDepth)
