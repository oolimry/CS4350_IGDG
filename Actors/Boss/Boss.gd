class_name Boss
extends Node2D

@onready var characterContainer : Node2D = $CharacterContainer
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

const MOVE_RIGHT_SKELETON_TRACK := NodePath(
	"CharacterContainer/Bones/Skeleton2D:position"
)
const MOVEMENT_OFFSET_TRACK := NodePath(".:animatedMovementOffset")

@export var health : Health
@export var fsm : BossFSM
var bossStaff : BossStaff
var bossAnimationStartPos : Vector2
var _character_transform_at_start := Transform2D.IDENTITY

var isMovementActive := false

func _ready() -> void:
	_standardize_move_right_tracks()

## Applies move_left's root-offset track structure once when the boss enters
## the tree; the authored scene resource remains unchanged.
func _standardize_move_right_tracks() -> void:
	if not animationPlayer.has_animation(&"move_right"):
		push_error("Boss AnimationPlayer is missing move_right")
		return

	var animation := animationPlayer.get_animation(&"move_right")
	var skeletonTrack := animation.find_track(
		MOVE_RIGHT_SKELETON_TRACK,
		Animation.TYPE_VALUE
	)
	if skeletonTrack < 0:
		push_error("move_right is missing its Skeleton2D position track")
		return

	animation.track_set_enabled(skeletonTrack, false)

	var methodTrack := animation.find_track(NodePath("."), Animation.TYPE_METHOD)
	if methodTrack < 0:
		methodTrack = animation.add_track(Animation.TYPE_METHOD)
		animation.track_set_path(methodTrack, NodePath("."))
	else:
		_clear_animation_track(animation, methodTrack)

	animation.track_insert_key(methodTrack, 0.0, {
		"method": &"prepareAnimatedMovement",
		"args": [],
	})
	animation.track_insert_key(methodTrack, animation.length, {
		"method": &"finishAnimatedMovement",
		"args": [],
	})

	var offsetTrack := animation.find_track(
		MOVEMENT_OFFSET_TRACK,
		Animation.TYPE_VALUE
	)
	if offsetTrack < 0:
		offsetTrack = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(offsetTrack, MOVEMENT_OFFSET_TRACK)
	else:
		_clear_animation_track(animation, offsetTrack)

	for keyIndex in animation.track_get_key_count(skeletonTrack):
		animation.track_insert_key(
			offsetTrack,
			animation.track_get_key_time(skeletonTrack, keyIndex),
			animation.track_get_key_value(skeletonTrack, keyIndex),
			animation.track_get_key_transition(skeletonTrack, keyIndex)
		)

func _clear_animation_track(animation : Animation, track : int) -> void:
	for keyIndex in range(animation.track_get_key_count(track) - 1, -1, -1):
		animation.track_remove_key(track, keyIndex)

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
	instance.animatedMovementOffset = Vector2.ZERO
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
