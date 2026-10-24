class_name BossHeadHurtBox
extends BossWeakPoint

@export var animPlayer : AnimationPlayer

func expressDamage(dmgSourceDirection : Vector2) -> void:
	if dmgSourceDirection == Vector2.LEFT:
		animPlayer.play("head_shake_left")
	else:
		animPlayer.play("head_shake_right")
	pass
