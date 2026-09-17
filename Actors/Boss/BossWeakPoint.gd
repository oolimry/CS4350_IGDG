class_name BossWeakPoint
extends AnimatableBody2D

@export var slashDamage := 2
@export var windDamage := 2
@export var explosionDamage := 2

signal bossTakeDamage(damage : int)

func onSlash(slashParams : Dictionary = {}, player : Player = null):
	bossTakeDamage.emit(slashDamage)

func onHitByBombExplosion():
	bossTakeDamage.emit(explosionDamage)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
