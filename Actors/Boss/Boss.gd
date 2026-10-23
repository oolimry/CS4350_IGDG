class_name Boss
extends Node2D

@onready var characterContainer : Node2D = $CharacterContainer
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer


@export var health : Health
@export var fsm : BossFSM
var bossStaff : BossStaff
var bossAnimationStartPos : Vector2
var _character_transform_at_start := Transform2D.IDENTITY

var isMovementActive := false

@export var animatedMovementOffset := Vector2.ZERO:
	set(value):
		if not isMovementActive:
			return
		
		var transformedPoint := _character_transform_at_start * value
		var worldDisplacement := (
			transformedPoint - _character_transform_at_start.origin
		)
				
		global_position = bossAnimationStartPos + worldDisplacement

func prepareAnimatedMovement() -> void:
	isMovementActive = false
	animatedMovementOffset = Vector2.ZERO
	
	bossAnimationStartPos = global_position
	_character_transform_at_start = characterContainer.global_transform
	
	isMovementActive = true

func finishAnimatedMovement() -> void:
	isMovementActive = false

# Static factory function acting as a custom constructor
static func create(basePos : Vector2, getPlayer : Callable, 
	addPersistentCallable : Callable, startingHP := 10) -> Boss:
		
	var scene = load("uid://dkht80tf3wlnf") as PackedScene
	var instance = scene.instantiate() as Boss
	instance.bossAnimationStartPos = basePos
	instance.global_position = basePos
	instance.z_index = -5
	instance.health.maxHealth = startingHP
	instance.health.currHealth = startingHP
	instance.bossStaff = BossStaff.create(basePos)
	instance.bossStaff.projFirer.setup(addPersistentCallable)
	addPersistentCallable.call(instance.bossStaff)

	instance.fsm.setup(func(): return instance, getPlayer, instance.bossStaff.projFirer)
	return instance

func start() -> void:
	fsm.startFSM()

func cleanup() -> void:
	bossStaff.projFirer.clearProjectiles()
	bossStaff.call_deferred("queue_free")
	call_deferred("queue_free")
