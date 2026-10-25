extends Node

var collected_items: Dictionary = {}

func is_item_collected(item_id: String) -> bool:
	return collected_items.has(item_id) and collected_items[item_id] == true

func collect_item(item_id: String) -> void:
	collected_items[item_id] = true
	print("Collected: ", item_id)
