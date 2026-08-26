@tool
class_name Element
extends StaticBody2D

@onready var timer: Timer = $Timer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D 

@onready var sprite : AnimatedSprite2D = $Sprite

@export var element : Enums.Elements:
	set(value):
		element = value
		if value == Enums.Elements.WIND:
			$Sprite.play("wind")
		elif value == Enums.Elements.FIRE:
			$Sprite.play("fire")

func _ready():
	timer.timeout.connect(respawnElement)
	
func onSlash(slashParams : Dictionary = {}, player : Player = null):
	timer.start()
	self.visible = false;
	collision_shape.set_deferred("monitoring", false)
	
	player.setElement(self.element)
	
	var slashDirection = slashParams.get(ScriptConstants.SLASH_DIRECTION_PARAM_NAME, \
		Enums.Directions.NONE)
	
	if slashDirection == Enums.Directions.DOWN: 
		player.pogo()

func respawnElement() -> void:
	collision_shape.set_deferred("monitoring", true)
	self.visible = true
	

	
