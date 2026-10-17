class_name Boss
extends Node2D

@export var health : Health
@export var fsm : BossFSM

# Static factory function acting as a custom constructor
static func create(basePos : Vector2, getPlayer : Callable, startingHP := 10) -> Boss:
		
	var scene = load("uid://dkht80tf3wlnf") as PackedScene
	var instance = scene.instantiate() as Boss
	instance.global_position = basePos
	instance.z_index = -5
	instance.health.maxHealth = startingHP
	instance.health.currHealth = startingHP
	var bossStaff = BossStaff.create(basePos)

	instance.fsm.setup(func(): return instance, getPlayer, bossStaff.bProjFirer)
	return instance

func start() -> void:
	fsm.startFSM()
