class_name BossStateIdle
extends BossState

## Minimum idle time, including movement. A longer animation always finishes.
@export var duration := 4
var randomizer : RandomNumberGenerator
var movementAnimName: StringName
var durationTimer : Timer

enum roomPosition {
	LEFT,
	MID,
	RIGHT
}

const MAX_MELEE_ATTACK_RANGE := 1500
const MIN_MELEE_ATTACK_RANGE := 400

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
	var boss : Node2D = getBoss.call()
	boss.get_node("CharacterContainer/Body/BossFootL").self_modulate = Color.RED
	boss.get_node("CharacterContainer/Body/BossFootR").self_modulate = Color.RED	
	durationTimer.timeout.connect(_end)
	durationTimer.start(duration)

	var ap = boss.get_node("AnimationPlayer") as AnimationPlayer
	ap.animation_finished.connect(_on_animation_finished)
	
	if currRoomPosition == roomPosition.LEFT:
		ap.play("move_right")
		currRoomPosition = roomPosition.MID
	elif currRoomPosition == roomPosition.RIGHT:
		ap.play("move_left")
		currRoomPosition = roomPosition.MID
	else:
		var rand = randomizer.randi() % 3
		if rand == 0:
			ap.play("move_left")
			currRoomPosition = roomPosition.LEFT
			
		elif rand == 1: 
			ap.play("move_right")
			currRoomPosition = roomPosition.RIGHT
		else:
			_end()
	movementAnimName = ap.assigned_animation

func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name != movementAnimName:
		return
	_end()
		

func _end() -> void:
	var ap: AnimationPlayer = getBoss.call().get_node("AnimationPlayer")
	# Locomotion now ends in the rest pose. Keep it rather than snapping IK
	# targets through RESET, which previously moved feet after touchdown.
	ap.animation_finished.disconnect(_on_animation_finished)
	durationTimer.timeout.disconnect(_end)
	durationTimer.stop()
	
	var p = getPlayer.call()
	var b = getBoss.call()
	var distToPlayer = abs(p.global_position.x - getBoss.call().global_position.x)
	
	if (distToPlayer <= MAX_MELEE_ATTACK_RANGE and \
		distToPlayer >= MIN_MELEE_ATTACK_RANGE) and \
		randomizer.randi() % 2 == 0:
		transitionTo.emit("MeleeAttack")
	elif randomizer.randi() % 2 == 0:
		transitionTo.emit("ProjectileStraight")
	else:
		transitionTo.emit("BeamFiring")
