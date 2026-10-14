class_name BossStateIdle
extends BossState

var durationTimer : Timer
@export var duration := 4
var randomizer : RandomNumberGenerator

enum roomPosition {
	LEFT,
	MID,
	RIGHT
}

var meleeAttackRange := 40 * 6

## The relative position the boss is in
## in reference to the boss Room [br]
## Not to be mistaken for the RoomDef roomPos
var currRoomPosition = roomPosition.MID

func setup(getB : Callable, getP : Callable, dependencies : Dictionary) -> void:
	super.setup(getB, getP, dependencies)
	durationTimer = dependencies["durationTimer"]
	
	randomizer = RandomNumberGenerator.new()
	randomizer.randomize()

func _start() -> void:
	durationTimer.timeout.connect(_end)
	durationTimer.start(duration)
	getBoss.call().get_node("CharacterContainer/Body/BossHead").modulate = Color.LIGHT_PINK
	
	var ap = getBoss.call().get_node("AnimationPlayer") as AnimationPlayer
	
	if currRoomPosition == roomPosition.LEFT:
		ap.play("move_right")
	elif currRoomPosition == roomPosition.RIGHT:
		ap.play("move_left")
	else:	
		if randomizer.randi() % 2 == 0:
			ap.play("move_left")
		else: 
			ap.play("move_right")
	
	await ap.animation_finished
	Glogger.debug("Boss is Idling")
	pass

func _end() -> void:
	durationTimer.timeout.disconnect(_end)
		
	var p = getPlayer.call()
	if abs(p.global_position.x - getBoss.call().global_position.x) \
		<= meleeAttackRange:
		transitionTo.emit("MeleeAttack")
	else:
		transitionTo.emit("ProjectileStraight")
	pass
	
