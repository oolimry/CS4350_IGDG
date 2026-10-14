extends StaticBody2D

@onready var killzone : Area2D = $KillZone
@export var hasKillzoneExclusion := false

func _process(delta):
	for body in killzone.get_overlapping_bodies():
		if body is Player:
			if body.isPurpleDashing:
				return
			else:
				if body.velocity == Vector2(0, 0) and !hasKillzoneExclusion:
					body.triggerDeath()
