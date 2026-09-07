class_name Chain
extends StaticBody2D

@export var attached_crate: Crate

func _ready() -> void:
	if attached_crate:
		attached_crate.attach(self)

func onSlash(slashParams : Dictionary = {}, player : Player = null):
	if attached_crate:
		attached_crate.detach()
		attached_crate = null

	queue_free()
