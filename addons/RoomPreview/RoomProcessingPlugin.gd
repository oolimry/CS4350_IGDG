@tool
extends EditorPlugin

var inspectorPlugin: RoomInspectorPlugin

const MENU_NAME := "Process Room"
const previewImageFolder := "res://Assets/Rooms/PreviewRoomImages/"

func _enter_tree() -> void:
	inspectorPlugin = RoomInspectorPlugin.new(processRoom)
	add_inspector_plugin(inspectorPlugin)
	Glogger.debug("[RoomProcessingPlugin] Inspector plugin registered.")

func _exit_tree() -> void:
	if inspectorPlugin:
		remove_inspector_plugin(inspectorPlugin)
		inspectorPlugin = null
	Glogger.debug("[RoomProcessingPlugin] Inspector plugin unregistered.")

func processRoom(definition: RoomDefinition) -> void:
	var defPath := definition.resource_path
	if defPath.is_empty():
		push_error("[RoomProcessingPlugin] Please save the RoomDefinition resource to disk first.")
		return

	var outputPngPath := previewImageFolder + defPath.get_file() + "_preview.png"
	
	var roomOpenSideDetect := RoomOpenSideDetector.new()
	var err : Error = await roomOpenSideDetect.detect(definition)
	
	if err != OK:
		push_error("[RoomProcessingPlugin] Failed to identify access points. Error code: %d" % err)
		return
		
	var previewGenerator := RoomPreviewGenerator.new()
	err = await previewGenerator.generateFromDefinition(definition, outputPngPath, self)
	if err != OK:
		push_error("[RoomProcessingPlugin] Failed to generate preview. Error code: %d" % err)
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
		definition.openSides = roomOpenSideDetect.open_sides
		ResourceSaver.save(definition, defPath)
		Glogger.debug("[RoomProcessingPlugin] Preview generated and saved to: ")
		Glogger.debug(outputPngPath)
