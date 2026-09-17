class_name Boss
extends Node2D

@export var health : Health

# Static factory function acting as a custom constructor
static func create(basePos : Vector2, startingHP := 10) -> Boss:
	var scene = load("uid://dkht80tf3wlnf") as PackedScene
	var instance = scene.instantiate() as Boss
	instance.global_position = basePos
	instance.z_index = -5
	instance.health.maxHealth = startingHP
	instance.health.currHealth = startingHP 
	return instance
