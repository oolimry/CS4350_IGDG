class_name BossProjFirer
extends Node2D

var addTopersistentActors : Callable

var activeLazer : Lazer
var getLazerDest : Callable
var projectileWarning : ProjectileWarning

signal beamAttackFinished

func setup(addTopersistentActors : Callable) -> void:
	self.addTopersistentActors = addTopersistentActors
	
func fireProjectile(p : ElementProjectile, dirInDegrees : float) -> void:
	p.global_position = global_position
	
	var vectorDirection = degreesToVector(dirInDegrees)
	
	p.fire(vectorDirection)
	p.add_to_group("BossProjectiles", false)
	addTopersistentActors.call(p, "BossProjectiles")

func createLazer(dest : Callable, onLazerFinish : Callable) -> Lazer:
	if activeLazer == null:
		activeLazer = Lazer.create(func(): return self , dest)
		addTopersistentActors.call(activeLazer, "BossProjectiles")
		activeLazer.global_position = global_position
		activeLazer.lazerFinished.connect(onLazerFinish)
	return activeLazer
	
func createProjectileWarning(dest : Callable) -> ProjectileWarning:
	if projectileWarning == null:
		projectileWarning = ProjectileWarning.create(func(): return self, dest)
		addTopersistentActors.call(projectileWarning, "BossProjectiles")
		
	return projectileWarning
	
func degreesToVector(degrees: float) -> Vector2:
	var radians = deg_to_rad(degrees)
	return Vector2(cos(radians), sin(radians))

func clearProjectiles() -> void:
	get_tree().call_group("BossProjectiles", "queue_free")
	if (activeLazer != null):
		activeLazer.queue_free()
		
	if (projectileWarning != null):
		projectileWarning.queue_free() 
