extends StaticBody2D

@onready var killzone : Area2D = $KillZone

func _process(delta):
	for body in killzone.get_overlapping_bodies():
		if body is Player:
			if body.isPurpleDashing:
				return
			else:
				body.triggerDeath()
