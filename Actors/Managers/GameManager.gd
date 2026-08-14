# GameManager class
# Keeps 
extends Node

@export var player : Player
@export var hudManager : HUDManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if hudManager.has_method("connectUI"):
		hudManager.connectUI(player)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
