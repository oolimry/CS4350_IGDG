class_name HUDManager
extends CanvasLayer

var maxHearts : int

func connectUI(p : Player) -> void:
	add_child(HealthBar.create(p.health))


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
