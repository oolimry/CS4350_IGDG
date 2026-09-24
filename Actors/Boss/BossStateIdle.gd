class_name BossStateIdle
extends BossState

var durationTimer : Timer
@export var duration := 4

func setup(getB : Callable, getP : Callable, dependencies : Dictionary) -> void:
	super.setup(getB, getP, dependencies)
	durationTimer = dependencies["durationTimer"]

func _start() -> void:
	durationTimer.timeout.connect(_end)
	durationTimer.start(duration)
	Glogger.debug("Boss is Idling")
	pass

func _end() -> void:
	## TODO: Change this
	transitionTo.emit("ProjectileStraight")
	pass
	
