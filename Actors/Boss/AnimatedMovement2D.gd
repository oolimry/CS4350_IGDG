class_name AnimatedMovement2D
extends Node
## A small 2D root-motion consumer, independent of Boss and animation names.
## A clip opts into locomotion by containing a MotionRoot:position value track.
## Other clips leave the actor in place and use their animated IK targets freely.
##
## Authoring locomotion (no Boss.gd edits):
## 1. Key MotionRoot.position for the desired displacement, in rig-local units.
##    Keep this marker beside the visual rig, never above it in the hierarchy.
## 2. Animate each limb's desired target position and its discrete `planted`
##    property. Use false during swing and true during ground contact.
## 3. At lift-off the desired target must meet the locked target. At touchdown,
##    use rest_position + (final_root_offset - touchdown_root_offset) to have
##    the locked limb arrive at its rest position when the body finishes moving.
## 4. Finish the rig and desired targets in the next clip's starting pose.
##    Restarting/replacing a clip establishes a baseline without moving the actor.
##
## This consumes animation displacement directly (no delta multiplier); Godot
## has already interpolated it using playback speed and elapsed animation time.

@export var actor: Node2D
@export var animation_player: AnimationPlayer
@export var motion_root: Node2D
@export var targets: Array[PlantedIKTarget2D] = []

var _needs_baseline := true
var _priming := false
var _motion_track := -1
var _animation: Animation
var _previous_offset := Vector2.ZERO
var _previous_time := 0.0

func _ready() -> void:
	# Run before Skeleton2D's physics IK (priority 0). Advancing manually keeps
	# animation -> actor movement -> contact resolution -> IK in that order.
	process_physics_priority = -10
	animation_player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	animation_player.animation_started.connect(_on_animation_started)
	animation_player.mixer_applied.connect(_on_pose_applied)

func _on_animation_started(_name: StringName) -> void:
	_needs_baseline = true

func _physics_process(delta: float) -> void:
	if not animation_player.is_playing():
		return
	if _needs_baseline:
		_needs_baseline = false
		_animation = animation_player.get_animation(animation_player.assigned_animation)
		var animation_root := animation_player.get_node(animation_player.root_node)
		var track_path := NodePath(str(animation_root.get_path_to(motion_root)) + ":position")
		_motion_track = _animation.find_track(track_path, Animation.TYPE_VALUE)
		for target in targets:
			target.release()
		# Sample the initial pose before advancing: a new clip's zero offset must
		# never undo the displacement accumulated by the preceding clip.
		_priming = true
		animation_player.advance(0.0)
		_priming = false
	animation_player.advance(delta)

func _on_pose_applied() -> void:
	var offset := motion_root.position
	var time := animation_player.current_animation_position
	if _motion_track >= 0 and not _priming:
		var displacement := offset - _previous_offset
		# Linear loops reset the marker to its first key. Include the remainder
		# of the previous cycle instead of interpreting the reset as backward motion.
		if _animation.loop_mode == Animation.LOOP_LINEAR and time < _previous_time:
			var start: Vector2 = _animation.value_track_interpolate(_motion_track, 0.0)
			var end: Vector2 = _animation.value_track_interpolate(_motion_track, _animation.length)
			displacement += end - start
		# MotionRoot is a marker, not the visual parent: translation is applied
		# exactly once to the actor, using the marker parent's scale and rotation.
		var frame := (motion_root.get_parent() as Node2D).global_transform
		actor.global_position += frame.basis_xform(displacement)
	_previous_offset = offset
	_previous_time = time
	for target in targets:
		target.resolve(_motion_track >= 0)
