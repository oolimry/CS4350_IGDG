@tool
class_name RespawningElement
extends Element

@onready var timer: Timer

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0
	timer.timeout.connect(respawnElement)
	
func onSlash(slashParams : Dictionary = {}, player : Player = null):
	if not active:
		return
		
	timer.start()
	super.onSlash(slashParams, player)

func respawnElement() -> void:
	collision_shape.set_deferred("monitoring", true)
	self.visible = true
	active = true
	

	
