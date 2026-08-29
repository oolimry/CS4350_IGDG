class_name PlayerSpawn
extends Marker2D

@export var referenceImage : Sprite2D

@export var roomPos : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	referenceImage.queue_free()
	pass # Replace with function body.
