class_name PlaceholderSlashableObject
extends StaticBody2D

func onSlash(slashParams : Dictionary = {}, player : Player = null):
	self.queue_free()
