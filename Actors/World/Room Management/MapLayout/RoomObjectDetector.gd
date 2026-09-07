@tool
class_name RoomObjectDetector
extends RefCounted

## Reference implementation for deriving which room boundaries contain an empty
## cell in the authored World TileMapLayer.
##
## A non-negative result is a bit mask of Side values. INVALID_RESULT means the
## authored scene does not satisfy the expected room contract.

const error: Error = ERR_INVALID_DATA
const WORLD_LAYER_NAME := &"World"

var open_sides := 0

func detect(roomDef : RoomDefinition) -> Error:
	
	# Instantiate the room scene
	var room := roomDef.gamePlayScene.instantiate()
	_disable_processing(room)
	
	var room_bounds = roomDef.previewBounds
	
	var room_2d := room as Node2D
	if room_2d == null:
		room.free()
		push_error("[RoomPreview] The gameplay scene root must be a Node2D.")
		return ERR_INVALID_DATA
	
	if room == null:
		push_error("[RoomAccessPointCheck] Cannot detect open sides from a null room.")
		return ERR_INVALID_DATA

	var world := room.get_node_or_null(NodePath(String(WORLD_LAYER_NAME))) as TileMapLayer
	if world == null:
		push_error(
			"[RoomAccessPointCheck] '%s' must have a direct TileMapLayer child named World."
			% room.name
		)
		return error

	if world.tile_set == null:
		push_error("[RoomAccessPointCheck] The World TileMapLayer must have a TileSet.")
		return error

	var tile_size := world.tile_set.tile_size
	if tile_size.x <= 0 or tile_size.y <= 0:
		push_error("[RoomAccessPointCheck] The World TileSet has an invalid tile size.")
		return error

	if not _bounds_align_with_tiles(room_bounds, tile_size):
		push_error(
			"[RoomAccessPointCheck] Room bounds %s are not divisible by World tile size %s."
			% [room_bounds, tile_size]
		)
		return error


	if _vertical_side_has_gap(room, world, room_bounds, tile_size, true):
		open_sides |= RoomDefinition.Side.LEFT
	if _vertical_side_has_gap(room, world, room_bounds, tile_size, false):
		open_sides |= RoomDefinition.Side.RIGHT
	if _horizontal_side_has_gap(room, world, room_bounds, tile_size, true):
		open_sides |= RoomDefinition.Side.TOP
	if _horizontal_side_has_gap(room, world, room_bounds, tile_size, false):
		open_sides |= RoomDefinition.Side.BOTTOM
	
	room.free()
	return OK

func _vertical_side_has_gap(
	room: Node2D,
	world: TileMapLayer,
	room_bounds: Rect2,
	tile_size: Vector2i,
	is_left: bool
) -> bool:
	var x := room_bounds.position.x + tile_size.x * 0.5
	if not is_left:
		x = room_bounds.end.x - tile_size.x * 0.5

	var row_count := int(room_bounds.size.y / tile_size.y)
	for row in range(row_count):
		var room_position := Vector2(
			x,
			room_bounds.position.y + (row + 0.5) * tile_size.y
		)
		if _is_empty_world_cell(room, world, room_position):
			return true

	return false

func _horizontal_side_has_gap(
	room: Node2D,
	world: TileMapLayer,
	room_bounds: Rect2,
	tile_size: Vector2i,
	is_top: bool
) -> bool:
	var y := room_bounds.position.y + tile_size.y * 0.5
	if not is_top:
		y = room_bounds.end.y - tile_size.y * 0.5

	var column_count := int(room_bounds.size.x / tile_size.x)
	for column in range(column_count):
		var room_position := Vector2(
			room_bounds.position.x + (column + 0.5) * tile_size.x,
			y
		)
		if _is_empty_world_cell(room, world, room_position):
			return true

	return false


func _is_empty_world_cell(
	room: Node2D,
	world: TileMapLayer,
	room_position: Vector2
) -> bool:
	# Room scenes currently offset World, so convert through global coordinates
	# instead of assuming that room-space and map-space origins are identical.
	var world_position := world.to_local(room.to_global(room_position))
	var map_position := world.local_to_map(world_position)
	return world.get_cell_source_id(map_position) == -1


func _bounds_align_with_tiles(
	room_bounds: Rect2,
	tile_size: Vector2i
) -> bool:
	return (
		is_equal_approx(fmod(room_bounds.size.x, float(tile_size.x)), 0.0)
		and is_equal_approx(fmod(room_bounds.size.y, float(tile_size.y)), 0.0)
	)

func _disable_processing(node: Node) -> void:
	node.process_mode = Node.PROCESS_MODE_DISABLED
	for child in node.get_children():
		_disable_processing(child)

## Integration reference
## =====================
##
## 1. Add this storage to RoomDefinition.gd. Keeping the enum there instead is
##    also reasonable if runtime systems need to interpret these flags without
##    depending on an editor-addon class.
##
## @export_flags("Left", "Right", "Top", "Bottom")
## var openSides: int = 0
##
## 2. In RoomPreviewGenerator, expose the last successful scan:
##
## var detectedOpenSides: int = 0
##
## 3. Immediately after `var room := sourceScene.instantiate()`, validate its
##    root and scan it before adding it to the SubViewport:
##
## var room_2d := room as Node2D
## if room_2d == null:
##     room.free()
##     push_error("[RoomPreview] The gameplay scene root must be a Node2D.")
##     return ERR_INVALID_DATA
##
## var scan_result := RoomOpenSideDetector.detect(room_2d, bounds)
## if scan_result == RoomOpenSideDetector.INVALID_RESULT:
##     room.free()
##     return ERR_INVALID_DATA
## detectedOpenSides = scan_result
##
## Continue with the existing `_disable_processing(room)` and
## `preview_root.add_child(room)` calls. This reuses the preview instance.
##
## 4. In RoomPreviewPlugin.generatePreviewForDefinition(), only after
##    generateFromDefinition() returns OK, assign the derived value alongside
##    previewTexture before the existing ResourceSaver.save() call:
##
## definition.previewTexture = imported_texture
## definition.openSides = generator.detectedOpenSides
## definition.emit_changed()
## var save_error := ResourceSaver.save(definition, defPath)
## if save_error != OK:
##     push_error("[RoomPreview] Failed to save RoomDefinition: %s" % save_error)
##
## This preserves the old .tres values whenever scene validation, side
## detection, or preview generation fails.
