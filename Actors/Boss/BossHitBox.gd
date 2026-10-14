class_name BossHitBox
extends Area2D

@export var hitDamage := 1


func _on_body_entered(body : Node2D) -> void:
	if body is Player:
		body.damageStateHandler.onHurt(1, false)
		body.applyKnockback()
