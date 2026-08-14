class_name PlaceholderSlashableObject
extends StaticBody2D

func onSlash(slashParams : Dictionary = {}):
	self.queue_free()
