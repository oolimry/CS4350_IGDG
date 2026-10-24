class_name BossStaff
extends Node2D

@export var projFirer : BossProjFirer
@export var gemSprite : Sprite2D

static func create(basePos : Vector2) -> BossStaff:
	var scene = load("uid://cdx0ithmk0s6c") as PackedScene
	var instance = scene.instantiate() as BossStaff
	instance.global_position = basePos
	return instance
