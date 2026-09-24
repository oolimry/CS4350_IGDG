@tool
class_name BossCheckPoint
extends CheckPoint

@export var isUniversal := false

func _ready() -> void:
	pass

func _draw() -> void:
	idleColour = Color.CORAL
	activeColour = Color.DARK_OLIVE_GREEN
	super._draw()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if !isUniversal:
		super._on_area_2d_body_entered(body)
	pass # Replace with function body.
