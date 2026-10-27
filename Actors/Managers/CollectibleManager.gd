extends Node

signal collected(item_id : StringName, item_texture : Texture)
var collected_items: Dictionary = {}

func is_item_collected(item_id: StringName) -> bool:
	return collected_items.has(item_id)

func collect_item(item_id: StringName, item_texture : Texture) -> void:
	if not is_item_collected(item_id):
		collected_items[item_id] = item_texture
		collected.emit(item_id, item_texture)
		Glogger.debug("Collected: " + item_id)
