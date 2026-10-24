class_name BossStateIdle
extends BossState

## Minimum idle time, including movement. A longer animation always finishes.
@export var duration := 4
var randomizer : RandomNumberGenerator
var movementAnimName: StringName

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
	
	randomizer = RandomNumberGenerator.new()
	randomizer.randomize()

func _start() -> void:
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
		
		var rand = randomizer.randi() % 3
		if rand == 0:
			ap.play("move_left")
			currRoomPosition = roomPosition.LEFT
		elif rand == 1: 
			ap.play("move_right")
			currRoomPosition = roomPosition.RIGHT
		
	movementAnimName = ap.assigned_animation

func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name != movementAnimName:
		return
	var ap: AnimationPlayer = getBoss.call().get_node("AnimationPlayer")
	ap.animation_finished.disconnect(_on_animation_finished)
	# Locomotion now ends in the rest pose. Keep it rather than snapping IK
	# targets through RESET, which previously moved feet after touchdown.
	_end()
		

func _end() -> void:	
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
