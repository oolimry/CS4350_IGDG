class_name Lazer
extends Node2D

@export var _getSource: Callable
@export var _getDest: Callable

@export var thickness: float = 300
@export var hitboxThicknessOffset : float = 2

@export var beam: AnimatedSprite2D

@export var aimDuration: float = 1.5
@export var lockDuration: float = 0.1
@export var beamDuration: float = 4.0
@export var trackingSpeed: float = 0.2
@export var damage: int = 2

@export var warning: Line2D
@export var ray: RayCast2D
@export var distancingRay : RayCast2D

@export var isBlockedByWall := false

enum State { IDLE, AIMING, LOCKED, FIRING }

var state := State.IDLE
var timeLeft: float = 0.0
var aimAngle: float = 0.0
var lockedEnd := Vector2.ZERO
 
# basically infinite
const MAX_RAY_DISTANCE := 100000

func _ready() -> void:
	beam.hide()
	warning.hide()
	ray.enabled = false
	beam.animation_finished.connect(stopAttack)

static func create(source : Callable, dest : Callable) -> Lazer:
	var scene = load("uid://c13vm6rsuma20") as PackedScene
	var instance = scene.instantiate() as Lazer
	instance._getSource = source
	instance._getDest = dest
	
	return instance

func startAttack() -> void:
	var _source : Node2D = _getSource.call()
	var _player : Node2D = _getDest.call()
	
	if state != State.IDLE:
		return
		
	if not is_instance_valid(_source) or not is_instance_valid(_player):
		return
	
	aimAngle = (
		_player.global_position - _source.global_position
	).angle()
	
	timeLeft = aimDuration
	state = State.AIMING
	warning.show()
	beam.hide()

func fire() -> void:
	warning.hide()
	
	var sourceStart : Vector2 = _getSource.call().global_position
	beam.show()
	# Show the beam even when it misses.
	update_beam(sourceStart, lockedEnd)
	beam.play()
	
	ray.global_position = sourceStart
	ray.target_position = ray.to_local(lockedEnd)
	ray.force_raycast_update()
	ray.enabled = true
	
	state = State.FIRING
	timeLeft = beamDuration

func cancel_attack() -> void:
	warning.hide()
	beam.hide()
	state = State.IDLE

func draw_warning(start: Vector2, end: Vector2) -> void:
	warning.show()
	warning.points = PackedVector2Array([
		warning.to_local(start),
		warning.to_local(end)
	])

func update_beam(start: Vector2, end: Vector2) -> void:
	global_position = start

	# Convert the destination to coordinates relative to this laser.
	var local_end := to_local(end)
	var frame_texture := beam.sprite_frames.get_frame_texture("default",0)
	var frame_size := frame_texture.get_size()
	var direction := end - start

	beam.centered = true
	beam.offset = Vector2.ZERO

	beam.global_position = (start + end) / 2.0
	beam.global_rotation = direction.angle() - PI / 2.0
	
	Glogger.debug(direction.length() / frame_size.y)
	
	var lengthModifier
	if isBlockedByWall:
		lengthModifier = direction.length() / frame_size.y
	else:
		# All I know is that this value works for MAX_RAY_DISTANCE
		lengthModifier = 350

	
	beam.global_scale = Vector2(
		thickness / frame_size.x,
		lengthModifier
	)
	
	ray.scale.y = thickness / frame_size.x - hitboxThicknessOffset 
	
func _physics_process(delta: float) -> void:
	var _source : Node2D = _getSource.call()
	var _player : Node2D = _getDest.call() 
	if state == State.IDLE:
		return
		
	timeLeft -= delta
	var sourceStart := _source.global_position
	match state:
		State.AIMING:
			if not is_instance_valid(_source) or not is_instance_valid(_player):
				cancel_attack()
				return

			var desired_angle := (
				_player.global_position - _source.global_position
			).angle()

			# Smaller trackingSpeed means more lag.
			aimAngle = lerp_angle(
				aimAngle,
				desired_angle,
				1.0 - exp(-trackingSpeed * delta)
			)
			
			var end = sourceStart + Vector2.RIGHT.rotated(aimAngle) * MAX_RAY_DISTANCE
			if isBlockedByWall:
				end = getWallEndpoint(sourceStart, aimAngle)
			
			draw_warning(sourceStart, end)

			if timeLeft <= 0.0:
				# Freeze both endpoints so the shot matches the warning.
				lockedEnd = end
				state = State.LOCKED
				timeLeft = lockDuration
				
		State.LOCKED:
			draw_warning(sourceStart, lockedEnd)
			
			if timeLeft <= 0.0:
				fire()
				
		State.FIRING:
			beam.show()
			
			ray.force_raycast_update()
			if beam.frame > 7 and beam.frame < 14 and ray.is_colliding():
				var possiblePlayer = ray.get_collider()
				if possiblePlayer is Player:
					possiblePlayer.damageStateHandler.onHurt(damage, false)
			

func stopAttack() -> void:
	beam.hide()
	state = State.IDLE
	ray.enabled = false

func getWallEndpoint(start: Vector2, angle: float) -> Vector2:
	var far_end := start + Vector2.RIGHT.rotated(angle) * MAX_RAY_DISTANCE

	distancingRay.global_position = start
	distancingRay.target_position = distancingRay.to_local(far_end)
	distancingRay.force_raycast_update()

	if distancingRay.is_colliding():
		var collider = distancingRay.get_collider() as Node2D
		if collider.get_parent().get_parent() is not BossStaff:
			return distancingRay.get_collision_point()

	return far_end
