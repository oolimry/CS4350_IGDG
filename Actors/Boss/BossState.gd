extends Resource
class_name BossState

signal transitionTo(stateID : StringName)

@export var stateID : StringName

var getBoss : Callable
var getPlayer : Callable

func setup(getB : Callable, getP : Callable, dependencies : Dictionary) -> void:
	getBoss = getB
	getPlayer = getP

func _start() -> void:
	pass

func _end() -> void:
	push_warning("Boss currently perpetually waiting on placeholder state")
	pass
	
# This gets run by the FSM 
func _physics_process(delta: float) -> void:
	pass

func getID() -> String:
	return stateID

func halt() -> void:
	pass
