class_name BossHitBox
extends Area2D

@export var hitDamage := 1

@export var nodeReference : Node2D

func _on_body_entered(body : Node2D) -> void:
	if body is Player:
		body.damageStateHandler.onHurt(1, false)
		body.applyKnockback(Vector2i(body.global_position.x - global_position.x, 0).clampi(-10,10))
