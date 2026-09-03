extends StaticBody2D

func onHitByBombExplosion():
	self.queue_free()
