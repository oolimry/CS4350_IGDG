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
	
