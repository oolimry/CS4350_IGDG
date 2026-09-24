class_name BossFSM
extends Node

@export var initialState : BossState
var currState : BossState

@export var stateIDLookup : Dictionary[StringName, BossState]

func setup(getBoss : Callable, getPlayer : Callable, 
	bProjFirer : BossProjFirer) -> void:
	
	var depedencies = {
		"projFirer": bProjFirer,
		"durationTimer" : $DurationTimer,
		"projTimer" : $ProjectileCoolDownTimer
	}
	
	for state in stateIDLookup.values():
		state.setup(getBoss, getPlayer, depedencies)
	
	initialState.setup(getBoss, getPlayer, depedencies)
	
	currState = initialState
	
func startFSM():
	initialState._start.call_deferred()
	#startState(initialState.getID())

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	currState._physics_process(delta)
	pass

func startState(roundID : String) -> void:
	currState = stateIDLookup[roundID]
	currState._start()
	pass

func endState() -> void:
	pass
