class_name HUDManager
extends CanvasLayer

var maxHearts : int

func connectUI(p : Player) -> void:
	var playerHP = p.health
	var instance = HealthBar.create(p.health)
	add_child(instance)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
