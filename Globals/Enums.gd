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
