## This class creates the Generate Preview Button in the Inspector whenever you are handling a RoomDefinition
## Clicking on the button generates the previewTexture used for the RoomDefinition

@tool
class_name RoomInspectorPlugin
extends EditorInspectorPlugin

## Use a Callable instead of holding a direct reference to avoid circular ref issues[br]
## Function that generates the preview
var onGenerateRequested: Callable

func _init(generateCallback: Callable = Callable()) -> void:
	onGenerateRequested = generateCallback

## Check if the object being handled is indeed a RoomDefinition instance (find the Resource .tres)
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
		if onGenerateRequested.is_valid():
			button.disabled = true
			button.text = "Generating..."
			await onGenerateRequested.call(definition)
			button.disabled = false
			button.text = "📸 Generate / Update Room Preview"
	)

	add_custom_control(button)
