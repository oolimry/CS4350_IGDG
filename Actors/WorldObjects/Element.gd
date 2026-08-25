class_name Element
extends Node2D

@onready var timer: Timer = $Timer
@onready var area: Area2D = $Area2D

func _ready():
	timer.timeout.connect(respawnElement)
	
func onSlash(slashParams : Dictionary = {}, player : Player = null):
		timer.start()
		self.visible = false;
		area.set_deferred("monitoring", false)

func respawnElement() -> void:
	area.set_deferred("monitoring", true)
	self.visible = true
	

	
