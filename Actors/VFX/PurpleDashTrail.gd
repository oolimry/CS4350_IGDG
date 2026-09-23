extends AnimatedSprite2D

func init(pos, params):
	self.global_position = pos
	play("default")
	await animation_finished
	queue_free()
