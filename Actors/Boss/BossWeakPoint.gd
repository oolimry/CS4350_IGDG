class_name BossWeakPoint
extends Area2D

@export var slashDamage := 2
@export var windDamage := 2
@export var explosionDamage := 2

signal bossTakeDamage(damage : int)

func onSlash(slashParams : Dictionary = {}, player : Player = null) -> void:
	if player.global_position < self.global_position:
		expressDamage(Vector2.LEFT)
	else:
		expressDamage(Vector2.RIGHT) 
	bossTakeDamage.emit(slashDamage)

func onHitByBombExplosion() -> void:
	expressDamage(Vector2.LEFT)
	bossTakeDamage.emit(explosionDamage)

func expressDamage(dmgSourceDirection : Vector2) -> void:
	pass
	
