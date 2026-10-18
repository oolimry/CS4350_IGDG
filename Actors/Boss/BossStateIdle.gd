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
	durationTimer.timeout.connect(_end)
	durationTimer.start(duration)
	
	var boss = getBoss.call()
	boss.get_node("CharacterContainer/Body/BossHead").modulate = Color.LIGHT_PINK
	
	var ap = boss.get_node("AnimationPlayer") as AnimationPlayer
	
	if currRoomPosition == roomPosition.LEFT:
		ap.play("move_right")
		currRoomPosition = roomPosition.MID
	elif currRoomPosition == roomPosition.RIGHT:
		ap.play("move_left")
		currRoomPosition = roomPosition.MID
	else:	
		if randomizer.randi() % 2 == 0:
			ap.play("move_left")
			currRoomPosition = roomPosition.RIGHT
		else: 
			ap.play("move_right")
			currRoomPosition = roomPosition.LEFT
	
	await ap.animation_finished
	reset_to_rest_pose(boss.get_node("CharacterContainer/Bones/Skeleton2D"))
	Glogger.debug("Boss is Idling")
	pass

func _end() -> void:
	durationTimer.timeout.disconnect(_end)
		
	var p = getPlayer.call()
	if (abs(p.global_position.x - getBoss.call().global_position.x) \
		<= meleeAttackRange) and randomizer.randi() % 2 == 0:
		transitionTo.emit("MeleeAttack")
	else:
		transitionTo.emit("ProjectileStraight")
	pass
	
func reset_to_rest_pose(skeleton : Skeleton2D) -> void:
	for child in skeleton.get_children():
		_apply_rest_recursive(child)

func _apply_rest_recursive(node: Node) -> void:
	if node is Bone2D:
		node.apply_rest()
	for child in node.get_children():
		_apply_rest_recursive(child)
