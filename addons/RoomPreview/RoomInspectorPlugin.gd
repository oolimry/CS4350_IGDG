@tool
class_name RoomInspectorPlugin
extends EditorInspectorPlugin

# Use a Callable instead of holding a direct reference to avoid circular ref issues
var on_generate_requested: Callable

func _init(generate_callback: Callable = Callable()) -> void:
	on_generate_requested = generate_callback

func _can_handle(object: Object) -> bool:
	if object == null:
		return false
	if object is RoomDefinition:
		return true
	var script := object.get_script() as Script
	if script != null:
		return script.get_global_name() == &"RoomDefinition" or script.resource_path.ends_with("RoomDefinition.gd")
	return false

func _parse_begin(object: Object) -> void:
	var definition := object as RoomDefinition
	if definition == null:
		return

	var button := Button.new()
	button.text = "📸 Generate / Update Room Preview"
	button.custom_minimum_size.y = 36
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	button.pressed.connect(func():
		if on_generate_requested.is_valid():
			button.disabled = true
			button.text = "Generating..."
			await on_generate_requested.call(definition)
			button.disabled = false
			button.text = "📸 Generate / Update Room Preview"
	)

	add_custom_control(button)
