class_name BossProjFirer
extends Node2D

var addTopersistentActors : Callable

var activeLazer : Lazer
var getLazerDest : Callable

signal beamAttackFinished

func setup(addTopersistentActors : Callable) -> void:
	self.addTopersistentActors = addTopersistentActors
	
func fireProjectile(p : ElementProjectile, dirInDegrees : float) -> void:
	p.global_position = global_position
	
	var vectorDirection = degreesToVector(dirInDegrees)
	
	p.fire(vectorDirection)
	p.add_to_group("BossProjectiles", false)
	addTopersistentActors.call(p, "BossProjectiles")

func fireLazer(dest : Callable, onLazerFinish : Callable) -> void:
	if activeLazer == null:
		activeLazer = Lazer.create(func(): return self , dest)
		addTopersistentActors.call(activeLazer, "BossProjectiles")
		activeLazer.global_position = global_position
		activeLazer.lazerFinished.connect(onLazerFinish)
	activeLazer.startAttack()
	
	
func degreesToVector(degrees: float) -> Vector2:
	var radians = deg_to_rad(degrees)
	return Vector2(cos(radians), sin(radians))

func clearProjectiles() -> void:
	get_tree().call_group("BossProjectiles", "queue_free")
	if (activeLazer != null):
		activeLazer.queue_free()
	
