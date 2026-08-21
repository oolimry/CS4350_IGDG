@tool
extends EditorPlugin

var inspectorPlugin: RoomInspectorPlugin

const MENU_NAME := "Generate Room Previews"
const previewImageFolder := "res://Assets/Rooms/PreviewRoomImages/"

func _enter_tree() -> void:
	inspectorPlugin = RoomInspectorPlugin.new(generatePreviewForDefinition)
	add_inspector_plugin(inspectorPlugin)
	Glogger.debug("[RoomPreviewPlugin] Inspector plugin registered.")

func _exit_tree() -> void:
	if inspectorPlugin:
		remove_inspector_plugin(inspectorPlugin)
		inspectorPlugin = null
	Glogger.debug("[RoomPreviewPlugin] Inspector plugin unregistered.")

func generatePreviewForDefinition(definition: RoomDefinition) -> void:
	var defPath := definition.resource_path
	if defPath.is_empty():
		push_error("[RoomPreview] Please save the RoomDefinition resource to disk first.")
		return

	var outputPngPath := previewImageFolder + defPath.get_file() + "_preview.png"

	var generator := RoomPreviewGenerator.new()
	var err: Error = await generator.generateFromDefinition(definition, outputPngPath, self)
	if err != OK:
		push_error("[RoomPreview] Failed to generate preview. Error code: %d" % err)
		return

	# Force immediate re-import of the generated PNG
	var efs := EditorInterface.get_resource_filesystem()
	efs.update_file(outputPngPath)
	efs.reimport_files(PackedStringArray([outputPngPath]))

	await get_tree().process_frame

	# Add the preview PNG to the Definition's previewTexture
	var imported_texture := load(outputPngPath) as Texture2D
	if imported_texture != null:
		definition.previewTexture = imported_texture
		ResourceSaver.save(definition, defPath)
		Glogger.debug("[RoomPreview] Preview generated and saved to: ")
		Glogger.debug(outputPngPath)
