# Written with help of GPT-6.1 Sol medium 
# tldr this ensures the feet that land on the ground
# remain planted when moving. Prevents the glide effect

class_name PlantedIKTarget2D
extends Node2D
## AnimationPlayer animates this node. CCDIK follows the separate IKTarget child.
## Key `planted` with a discrete track: false at lift-off, true at touchdown.

@export var planted := false
@onready var ik_target: Node2D = $IKTarget

var _locked := false
var _contact_position := Vector2.ZERO

func release() -> void:
	_locked = false
	planted = false

func resolve(lock_enabled: bool) -> void:
	if lock_enabled and planted:
		if not _locked:
			_contact_position = global_position
			_locked = true
		# Recompute the child's local position through global_position, cancelling
		# all parent motion (including CharacterContainer's scale).
		ik_target.global_position = _contact_position
	else:
		_locked = false
		ik_target.global_position = global_position
