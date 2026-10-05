@tool
class_name MovingElement
extends RespawningElement

@export var speed: float = 5.0
@export var distance: float = 200.0

var start_x: float
var time_passed: float = 0.0

func _ready():
	super() 
	start_x = position.x

func _process(delta):
	
	if Engine.is_editor_hint():
		return 
	time_passed += delta * speed
	position.x = start_x + (sin(time_passed) * distance)
