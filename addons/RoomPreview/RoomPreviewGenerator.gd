@tool
class_name RoomPreviewGenerator
extends RefCounted

func generate_from_definition(
	definition: RoomDefinition,
	output_path: String,
	plugin_context: Node
) -> Error:
	if definition == null:
		return ERR_INVALID_PARAMETER

	var source_scene: PackedScene = definition.gamePlayScene
	if source_scene == null:
		return ERR_FILE_NOT_FOUND

	return await generate_from_scene(
		source_scene,
		definition.previewBounds,
		definition.previewSize,
		output_path,
		plugin_context
	)

func generate_from_scene(
	source_scene: PackedScene,
	bounds: Rect2,
	image_size: Vector2i,
	output_path: String,
	plugin_context: Node
) -> Error:
	if source_scene == null or image_size.x <= 0 or image_size.y <= 0 or plugin_context == null:
		return ERR_INVALID_PARAMETER

	var tree := plugin_context.get_tree()
	if tree == null:
		return ERR_UNCONFIGURED

	# 1. Setup isolated SubViewport with its own 2D world
	var viewport := SubViewport.new()
	viewport.name = "OffscreenPreviewViewport"
	viewport.size = image_size
	viewport.transparent_bg = true
	viewport.world_2d = World2D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	var preview_root := Node2D.new()
	viewport.add_child(preview_root)

	# 2. Instantiate and add room scene
	var room := source_scene.instantiate()
	_disable_processing(room)
	preview_root.add_child(room)

	# 3. Setup Camera framing
	var camera := Camera2D.new()
	if bounds.size.x > 0 and bounds.size.y > 0:
		camera.position = bounds.position + (bounds.size / 2.0)
		camera.zoom = Vector2(
			float(image_size.x) / bounds.size.x,
			float(image_size.y) / bounds.size.y
		)
	else:
		# Default fallback centering
		camera.position = Vector2(image_size) / 2.0
	
	preview_root.add_child(camera)

	# 4. Attach viewport to editor tree hierarchy via plugin_context
	plugin_context.add_child(viewport)

	# 5. Let the SceneTree register nodes, update canvas transforms, and draw
	await tree.process_frame
	RenderingServer.force_draw()
	await tree.process_frame

	# 6. Retrieve and save texture data
	var texture := viewport.get_texture()
	var error: Error = ERR_CANT_CREATE

	if texture != null:
		var image := texture.get_image()
		if image != null and not image.is_empty():
			error = image.save_png(output_path)
		else:
			push_error("[RoomPreviewGenerator] Captured texture image data is empty.")
	else:
		push_error("[RoomPreviewGenerator] Viewport texture was null.")

	# 7. Clean up offscreen nodes
	viewport.queue_free()
	return error

func _disable_processing(node: Node) -> void:
	node.process_mode = Node.PROCESS_MODE_DISABLED
	for child in node.get_children():
		_disable_processing(child)
