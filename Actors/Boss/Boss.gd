class_name Boss
extends CharacterBody2D

@export var health : Health

# Static factory function acting as a custom constructor
static func create(startingPos : Vector2, startingHP := 10) -> Boss:
	var scene = load("uid://dkht80tf3wlnf") as PackedScene
	var instance = scene.instantiate() as Boss
	instance.global_position = startingPos
	
	instance.health.maxHealth = startingHP
	instance.health.currHealth = startingHP 
	return instance
