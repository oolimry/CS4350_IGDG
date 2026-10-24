class_name Boss
extends Node2D

@onready var characterContainer : Node2D = $CharacterContainer
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

@export var health : Health
@export var fsm : BossFSM
var bossStaff : BossStaff

# Static factory function acting as a custom constructor
static func create(basePos : Vector2, getPlayer : Callable, 
	addPersistentCallable : Callable, startingHP := 10) -> Boss:
		
	var scene = load("uid://dkht80tf3wlnf") as PackedScene
	var instance = scene.instantiate() as Boss
	instance.global_position = basePos
	instance.z_index = -5
	instance.health.maxHealth = startingHP
	instance.health.currHealth = startingHP
	instance.bossStaff = BossStaff.create(basePos)
	instance.bossStaff.projFirer.setup(addPersistentCallable)
	addPersistentCallable.call(instance.bossStaff)

	instance.fsm.setup(func(): return instance, getPlayer, instance.bossStaff)
	return instance

func start() -> void:
	fsm.startFSM()

func cleanup() -> void:
	bossStaff.projFirer.clearProjectiles()
	bossStaff.call_deferred("queue_free")
	call_deferred("queue_free")
