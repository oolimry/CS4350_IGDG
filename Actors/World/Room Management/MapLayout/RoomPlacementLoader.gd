extends Node

# Node which stores all the room Previews
@export var roomPreviewsRoot : Node

var previewImageSize : Vector2i
var roomSceneSize : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generateLayout(roomPreviewsRoot : Node) -> Dictionary[Vector2i, RoomDefinition]:
	var roomLayout : Dictionary[Vector2i, RoomDefinition]
	var key := Vector2i(0,0)
	var roomDef : RoomDefinition
	for preview in roomPreviewsRoot.get_children():
		if preview is not RoomPreviewPlacement:
			pass
		
		roomDef = preview.roomDefinition
		key.x = preview.x % RoomDefinition.previewImageSize.x
		key.y = preview.y % RoomDefinition.previewImageSize.y
		if !roomLayout.find_key(key).is_null():
			push_error("Trying to load a room at the same grid coords. ", key,
				" already has ", roomLayout.find_key(key).roomName, " but trying to load"
				, roomDef.roomName)
		else:
			roomLayout[key] = roomDef
	
	roomPreviewsRoot.queue_free()
	return roomLayout
