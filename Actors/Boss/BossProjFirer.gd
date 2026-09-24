class_name BossProjFirer
extends Node2D

var addTopersistentActors : Callable

func setup(addTopersistentActors : Callable) -> void:
	self.addTopersistentActors = addTopersistentActors
	
func fireProjectile(p : ElementProjectile, dirInDegrees : float) -> void:
	p.global_position = global_position
	
	var vectorDirection = degreesToVector(dirInDegrees)
	
	p.fire(vectorDirection)
	
	addTopersistentActors.call(p)

func degreesToVector(degrees: float) -> Vector2:
	var radians = deg_to_rad(degrees)
	return Vector2(cos(radians), sin(radians))
