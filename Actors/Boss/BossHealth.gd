class_name BossHealth
extends Health

@export var timer : Timer

var isInvuln := false

func _on_boss_take_damage(damage: int) -> void:
	if !isInvuln:
		takeDamage(damage)
		timer.start()
		isInvuln = true
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	isInvuln = false
	pass # Replace with function body.
