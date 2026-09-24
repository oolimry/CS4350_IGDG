class_name ProjectileMovementStraightLine
extends ProjectileMovementEquation

## Override wtv velocity the projectile currently has
@export var fixedSpeed = 20;

## The direction is obtained by the currVelocity
func calculateMovement(globalPosition : Vector2, \
	currVelocity : Vector2, age : float, delta : float) -> Vector2:
		
	return globalPosition + fixedSpeed * currVelocity.normalized() * delta
