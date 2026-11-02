class_name BossFSM
extends Node

@export var initialState : BossState
var currState : BossState

@export var stateIDLookup : Dictionary[StringName, BossState]

func setup(getBoss : Callable, getPlayer : Callable, 
	bStaff : BossStaff) -> void:
	
	var depedencies = {
		"bossStaff": bStaff,
		"durationTimer" : $DurationTimer,
		"projTimer" : $ProjectileCoolDownTimer
	}
	
	for state in stateIDLookup.values():
		state.setup(getBoss, getPlayer, isPreconditionFulfilled, depedencies)
		state.transitionTo.connect(startState)
	
	initialState.setup(getBoss, getPlayer, isPreconditionFulfilled, depedencies)
	initialState.transitionTo.connect(startState)
	
	
	currState = initialState
	
func startFSM():
	initialState._start.call_deferred()
	#startState(initialState.getID())

func isPreconditionFulfilled(stateID : StringName) -> bool:
	currState = stateIDLookup[stateID]
	return currState._isPreconditionFulfilled()
	
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	currState._physics_process(delta)
	pass

func startState(stateID : StringName) -> void:
	currState = stateIDLookup[stateID]
	currState._start()
	pass

func endState() -> void:
	pass
