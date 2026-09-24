@tool
class_name Element
extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D 

@onready var sprite : AnimatedSprite2D = $Sprite

var active = true

@export var element : Enums.Elements:
	set(value):
		if is_instance_valid($Sprite):
			element = value
			if value == Enums.Elements.WIND:
				$Sprite.play("wind")
			elif value == Enums.Elements.FIRE:
				$Sprite.play("fire")
			elif value == Enums.Elements.PURPLE:
				$Sprite.play("purple")

func onSlash(slashParams : Dictionary = {}, player : Player = null):
	if not active:
		return
		
	self.visible = false
	active = false
	collision_shape.set_deferred("monitoring", false)
	player.setElement(self.element)
	
	var slashDirection = slashParams.get(ScriptConstants.SLASH_DIRECTION_PARAM_NAME, \
		Enums.Directions.NONE)
	
	if slashDirection == Enums.Directions.DOWN: 
		player.pogo()
		
	if element == Enums.Elements.FIRE:
		VfxManager.createVFX(VfxManager.FireElementCollectedVFX, self.global_position, {
			VFXManager_class.Params.PLAYER : player
		})
	elif element == Enums.Elements.WIND:
		VfxManager.createVFX(VfxManager.WindElementCollectedVFX, self.global_position, {
			VFXManager_class.Params.PLAYER : player
		})
	elif element == Enums.Elements.PURPLE:
		VfxManager.createVFX(VfxManager.PurpleElementCollectedVFX, self.global_position, {
			VFXManager_class.Params.PLAYER : player
		})
