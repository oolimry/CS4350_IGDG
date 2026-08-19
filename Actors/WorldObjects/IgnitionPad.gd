class_name IgnitionPad
extends StaticBody2D

@export var direction : Enums.Directions = Enums.Directions.RIGHT
const cooldown = 0.25
var isActive = true

func onSlash(slashParams : Dictionary = {}, player : Player = null):
	# TODO check you're slashing in the right direction
	
	if not is_instance_valid(player):
		return
	
	if not isActive:
		return
		
	var slashDirection = slashParams.get(ScriptConstants.SLASH_DIRECTION_PARAM_NAME, \
		Enums.Directions.NONE)
	
	if Enums.getOppositeDirection(direction) != slashDirection:
		return
	
	isActive = false
	self.modulate.a = 0.5
	
	Glogger.debug(self.direction)
	player.launchByIgnitionPad(self.direction)
	
	await get_tree().create_timer(cooldown).timeout
	
	isActive = true
	self.modulate.a = 1
