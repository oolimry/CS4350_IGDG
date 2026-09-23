@tool
class_name IgnitionPad
extends StaticBody2D

var isActive = true

@onready var sprite = $Sprite2D
@onready var ignitionPadVFXEmitter = $IgnitionPadExplosionVFX

@export var direction : Enums.Directions:
	set(value):
		direction = value
		self.rotation = Enums.getVectorOfDirection(direction).angle()


func onSlash(slashParams : Dictionary = {}, player : Player = null):
	# TODO check you're slashing in the right direction
	
	Glogger.debug(slashParams)
	
	if not is_instance_valid(player):
		return
	
	if not isActive:
		return
	
	var slashElement = slashParams.get(ScriptConstants.SLASH_ELEMENT_PARAM_NAME, Enums.Elements.NONE)
	
	if slashElement != Enums.Elements.FIRE:
		return	
		
	var slashDirection = slashParams.get(ScriptConstants.SLASH_DIRECTION_PARAM_NAME, \
		Enums.Directions.NONE)
	
	if Enums.getOppositeDirection(direction) != slashDirection:
		return
	
	isActive = false
	
	Glogger.debug(self.direction)
	player.launchByIgnitionPadOrBomb(self.direction)
	
	sprite.play("launch")
	#ignitionPadVFXEmitter.emitting = true
	await sprite.animation_finished
	
	isActive = true
	self.modulate.a = 1
