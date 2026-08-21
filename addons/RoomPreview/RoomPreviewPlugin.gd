@tool
extends EditorPlugin

var inspector_plugin: RoomInspectorPlugin
var plugin = preload("uid://bmh0kyrauxlcf")

const GENERATOR_SCRIPT = preload("uid://culdmrkunfuga") # RoomPreviewGenerator.gd
const ROOM_DEFINITION_SCRIPT = preload("uid://cij17tnbhukil") # RoomDefinition.gd

const MENU_NAME := "Generate Room Previews"

func _enter_tree() -> void:
	inspector_plugin = RoomInspectorPlugin.new(generate_preview_for_definition)
	add_inspector_plugin(inspector_plugin)
	print("[RoomPreviewPlugin] Inspector plugin registered.")

func _exit_tree() -> void:
	if inspector_plugin:
		remove_inspector_plugin(inspector_plugin)
		inspector_plugin = null
	print("[RoomPreviewPlugin] Inspector plugin unregistered.")

func generate_preview_for_definition(definition: RoomDefinition) -> void:
	var def_path := definition.resource_path
	if def_path.is_empty():
		push_error("[RoomPreview] Please save the RoomDefinition resource to disk first.")
		return

	var output_png_path := def_path.get_basename() + "_preview.png"

	var generator := GENERATOR_SCRIPT.new()
	var err: Error = await generator.generate_from_definition(definition, output_png_path, self)
	if err != OK:
		push_error("[RoomPreview] Failed to generate preview. Error code: %d" % err)
		return

	# Force immediate re-import of the generated PNG
	var efs := EditorInterface.get_resource_filesystem()
	efs.update_file(output_png_path)
	efs.reimport_files(PackedStringArray([output_png_path]))

	await get_tree().process_frame

	var imported_texture := load(output_png_path) as Texture2D
	if imported_texture != null:
		definition.previewTexture = imported_texture
		ResourceSaver.save(definition, def_path)
		print("[RoomPreview] Preview generated and saved to: ", output_png_path)
