extends BossState
class_name BossStateMeleeAttack

var randomizer : RandomNumberGenerator
@export var faceWipeRadius : float = 400

func setup(getB : Callable, getP : Callable, isPreconditionFulfilled : Callable,
	dependencies : Dictionary) -> void:
	super.setup(getB, getP, isPreconditionFulfilled, dependencies)
	randomizer = RandomNumberGenerator.new()
	randomizer.randomize()

func _isPreconditionFulfilled() -> bool:
	var player : Node2D = getPlayer.call()
	var boss : Node2D = getBoss.call()
	return isPlayerAtFeet(boss, player) or isPlayerNearHead(boss, player)

func _start() -> void:
	var player : Node2D = getPlayer.call()
	var boss : Node2D = getBoss.call()
	var ap = boss.get_node("AnimationPlayer") as AnimationPlayer
	
	if getPlayer.call().global_position.x <= getBoss.call().global_position.x:
		if isPlayerNearHead(boss, player):
			ap.play("arm_r_face_swipe")
		elif isPlayerAtFeet(boss, player) and randomizer.randi() % 2 == 0:
			ap.play("foot_r_stomp")
		elif randomizer.randi() % 2 == 0:
			ap.play("arm_r_hit")
		else:
			ap.play("arm_r_swing")
	else:
		if isPlayerNearHead(boss, player):
			ap.play("arm_r_face_swipe")
		elif isPlayerAtFeet(boss, player) and randomizer.randi() % 2 == 0:
			ap.play("foot_r_stomp")
		elif randomizer.randi() % 2 == 0:
			ap.play("arm_l_hit")
		else:
			ap.play("arm_l_swing")
			
	await ap.animation_finished
	_end()

func _end() -> void:
	transitionTo.emit("Idle")
	pass
	
func isPlayerNearHead(boss : Node2D, player : Node2D) -> bool:
	var headReferencePoint : Vector2 = \
		boss.get_node("CharacterContainer/Bones/Skeleton2D/Hip/Torso/Head/HeadHurtBox").global_position

	var isPlayerNearHead = headReferencePoint.distance_squared_to(player.global_position) \
		<= faceWipeRadius * faceWipeRadius
	return isPlayerNearHead
	
func isPlayerAtFeet(boss : Node2D, player : Node2D) -> bool:
	var feetReferencePoint : Vector2 = \
		boss.get_node("CharacterContainer/FootReference").global_position
	
	var isPlayerAtFeetLevel = feetReferencePoint.y < player.global_position.y
	return isPlayerAtFeetLevel
	
