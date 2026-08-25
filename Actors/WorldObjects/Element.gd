class_name Element
extends StaticBody2D

@onready var timer: Timer = $Timer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D 


func _ready():
	timer.timeout.connect(respawnElement)
	
func onSlash(slashParams : Dictionary = {}, player : Player = null):
	timer.start()
	self.visible = false;
	collision_shape.set_deferred("monitoring", false)

func respawnElement() -> void:
	collision_shape.set_deferred("monitoring", true)
	self.visible = true
	

	
