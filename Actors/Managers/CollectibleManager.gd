extends Node

signal collected(item_id : StringName, item_texture : Texture)
var collected_items: Dictionary = {}

func is_item_collected(item_id: StringName) -> bool:
	return collected_items.has(item_id) and collected_items[item_id] == true

func collect_item(item_id: StringName, item_texture : Texture) -> void:
	collected_items[item_id] = item_texture
	collected.emit(item_id, item_texture)
	Glogger.debug("Collected: " + item_id)
