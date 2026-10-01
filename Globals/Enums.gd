class_name Enums
extends RefCounted

enum Directions {
	NONE,
	LEFT,
	RIGHT,
	UP,
	DOWN
}

enum Elements {
	NONE,
	WIND,
	FIRE,
	PURPLE,
}

enum Layers {
	PLAYER = 1,
	SOLID = 2,
	HAZARD = 4,
	SLASHABLE = 8,
	PLATFORM = 16
}

static func getOppositeDirection(direction : Directions):
	if direction == Directions.NONE:
		return Directions.NONE
	if direction == Directions.LEFT:
		return Directions.RIGHT
	if direction == Directions.RIGHT:
		return Directions.LEFT
	if direction == Directions.UP:
		return Directions.DOWN
	if direction == Directions.DOWN:
		return Directions.UP

static func getVectorOfDirection(direction : Directions):
	if direction == Directions.NONE:
		return Vector2.ZERO
	elif direction == Directions.RIGHT:
		return Vector2.RIGHT
	elif direction == Directions.LEFT:
		return Vector2.LEFT
	elif direction == Directions.DOWN:
		return Vector2.DOWN
	elif direction == Directions.UP:
		return Vector2.UP
