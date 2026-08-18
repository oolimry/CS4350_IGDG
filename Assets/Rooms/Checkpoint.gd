class_name CheckPoint
extends Node2D

signal checkPointReached(pos : Vector2i)

@export var referenceImage : Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	referenceImage.queue_free()
	pass # Replace with function body.

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	
	checkPointReached.emit(self)
	pass # Replace with function body.
