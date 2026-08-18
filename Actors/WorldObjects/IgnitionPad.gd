class_name IgnitionPad
extends StaticBody2D

@export var direction : Enums.Directions = Enums.Directions.RIGHT

func onSlash(slashParams : Dictionary = {}, player : Player = null):
	# TODO check you're slashing in the right direction
	
	if not is_instance_valid(player):
		return
	
	Glogger.debug(self.direction)
	player.launchByIgnitionPad(self.direction)
	
