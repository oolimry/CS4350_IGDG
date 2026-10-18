extends BossState
class_name BossStateMeleeAttack

var randomizer : RandomNumberGenerator

func setup(getB : Callable, getP : Callable, dependencies : Dictionary) -> void:
	super.setup(getB, getP, dependencies)
	randomizer = RandomNumberGenerator.new()
	randomizer.randomize()

func _start() -> void:
	var ap = getBoss.call().get_node("AnimationPlayer") as AnimationPlayer
	if getPlayer.call().global_position.x <= getBoss.call().global_position.x:
		if randomizer.randi() % 2 == 0:
			ap.play("arm_r_hit")
		else:
			ap.play("arm_r_swing")
	else:
		if randomizer.randi() % 2 == 0:
			ap.play("arm_l_hit")
		else:
			ap.play("arm_l_swing")
			
	await ap.animation_finished
	reset_to_rest_pose(getBoss.call().get_node("CharacterContainer/Bones/Skeleton2D"))

	_end()

func _end() -> void:
	transitionTo.emit("Idle")
	pass

func reset_to_rest_pose(skeleton : Skeleton2D) -> void:
	for child in skeleton.get_children():
		_apply_rest_recursive(child)

func _apply_rest_recursive(node: Node) -> void:
	if node is Bone2D:
		node.apply_rest()
	for child in node.get_children():
		_apply_rest_recursive(child)
