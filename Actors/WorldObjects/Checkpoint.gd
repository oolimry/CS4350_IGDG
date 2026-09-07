@tool
class_name CheckPoint
extends Node2D

signal checkPointReached(pos : Vector2i)

@export var referenceImage : Sprite2D

@export var roomPos : Vector2i
@export var shouldSpawnPlayer := false

@export var reference_texture: Texture2D:
	set(value):
		reference_texture = value
		queue_redraw()
@export var textureOffset : Vector2

@export var reference_scale := Vector2.ONE:
	set(value):
		reference_scale = value
		queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint() or reference_texture == null:
		return

	var draw_size := reference_texture.get_size() * reference_scale
	var draw_position := Vector2(
		-draw_size.x * 0.5 + textureOffset.x,
		-draw_size.y * 0.5 + textureOffset.y
	)

	draw_texture_rect(
		reference_texture,
		Rect2(draw_position, draw_size),
		false,
		Color(0.0, 0.4, 1.0, 1.0)
	)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	
	checkPointReached.emit(self)
	pass # Replace with function body.
	
