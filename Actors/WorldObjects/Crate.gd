class_name Crate
extends RigidBody2D

@export var attached_chain: Chain

func attach(chain: Chain) -> void:
	attached_chain = chain
	freeze = true
	
func detach() -> void:
	attached_chain = null
	freeze = false
	
func onSlash(slashParams : Dictionary = {}, player : Player = null):
	if attached_chain:
		attached_chain.attached_crate = null
		attached_chain = null

	queue_free()
