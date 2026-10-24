class_name BossStateIdle
extends BossState

var durationTimer : Timer
## Minimum idle time, including movement. A longer animation always finishes.
@export var duration := 4
var randomizer : RandomNumberGenerator
var _movement_finished := false
var _minimum_duration_finished := false
var _movement_animation: StringName

enum roomPosition {
	LEFT,
	MID,
	RIGHT
}

var meleeAttackRange := 1500

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
	_movement_finished = false
	_minimum_duration_finished = false
	durationTimer.timeout.connect(_on_minimum_duration_finished, CONNECT_ONE_SHOT)
	durationTimer.start(duration)
	
	var boss = getBoss.call()
	boss.get_node("CharacterContainer/Body/BossHead").modulate = Color.LIGHT_PINK
	
	var ap = boss.get_node("AnimationPlayer") as AnimationPlayer
	ap.animation_finished.connect(_on_animation_finished)
	
	if currRoomPosition == roomPosition.LEFT:
		ap.play("move_right")
		currRoomPosition = roomPosition.MID
	elif currRoomPosition == roomPosition.RIGHT:
		ap.play("move_left")
		currRoomPosition = roomPosition.MID
	else:	
		if randomizer.randi() % 2 == 0:
			ap.play("move_left")
			currRoomPosition = roomPosition.LEFT
		else: 
			ap.play("move_right")
			currRoomPosition = roomPosition.RIGHT
	_movement_animation = ap.assigned_animation

func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name != _movement_animation:
		return
	var ap: AnimationPlayer = getBoss.call().get_node("AnimationPlayer")
	ap.animation_finished.disconnect(_on_animation_finished)
	# Locomotion now ends in the rest pose. Keep it rather than snapping IK
	# targets through RESET, which previously moved feet after touchdown.
	_movement_finished = true
	_try_end()

func _on_minimum_duration_finished() -> void:
	_minimum_duration_finished = true
	_try_end()

func _try_end() -> void:
	if _movement_finished and _minimum_duration_finished:
		_end()

func _end() -> void:
	durationTimer.stop()
	
	var p = getPlayer.call()
	if (abs(p.global_position.x - getBoss.call().global_position.x) \
		<= meleeAttackRange) and randomizer.randi() % 2 == 0:
		transitionTo.emit("MeleeAttack")
	elif randomizer.randi() % 2 == 0:
		transitionTo.emit("ProjectileStraight")
	else:
		transitionTo.emit("BeamFiring")
	
func reset_to_rest_pose(skeleton : Skeleton2D) -> void:
	for child in skeleton.get_children():
		_apply_rest_recursive(child)

func _apply_rest_recursive(node: Node) -> void:
	if node is Bone2D:
		node.apply_rest()
	for child in node.get_children():
		_apply_rest_recursive(child)
