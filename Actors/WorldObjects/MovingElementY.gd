@tool
class_name MovingElementY
extends RespawningElement

@export var speed: float = 5.0
@export var distance: float = 200.0

var start_y: float
var time_passed: float = 0.0

func _ready():
	super() 
	start_y = position.y

func _process(delta):
	
	if Engine.is_editor_hint():
		return 
	time_passed += delta * speed
	position.y = start_y + (sin(time_passed) * distance)
