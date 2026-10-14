extends BossState
class_name BossStateMeleeAttack

func _start() -> void:
	var ap = getBoss.call().get_node("AnimationPlayer") as AnimationPlayer
	if getPlayer.call().global_position.x <= getBoss.call().global_position.x:
		ap.play("arm_r_hit")
	else:
		ap.play("arm_l_hit")
	await ap.animation_finished
	_end()

func _end() -> void:
	transitionTo.emit("Idle")
	pass
