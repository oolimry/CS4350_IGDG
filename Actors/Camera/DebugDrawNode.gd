class_name DebugDrawNode
extends Node2D

var outer_radii : Vector2
var inner_scale : Vector2

func _init(b, c) -> void:
	outer_radii = b
	inner_scale = c

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _draw() -> void:
	var inner_half_size := outer_radii * inner_scale

	Glogger.debug(outer_radii)
	draw_rect(
		Rect2(-outer_radii, outer_radii * 2.0),
		Color.RED, true, 2.0
	)
	draw_rect(
		Rect2(-inner_half_size, inner_half_size * 2.0),
		Color.GREEN, true, 2.0
	)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
