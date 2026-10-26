class_name ProjectileWarning
extends Polygon2D

@export var warningAngleDegrees = 24.0

const NUM_SEGMENTS := 24
const WARNING_CONE_LENGTH := 1200.0


var warningTimeLeft := 0.0
var halfAngle

var aimAngle: float = 0.0

var _getSource : Callable
var _getDest : Callable

static func create(source : Callable, dest : Callable) -> ProjectileWarning:
	#TODO: CHANGE
	var scene = load("uid://rd5txna8401b") as PackedScene
	var instance = scene.instantiate() as ProjectileWarning
	instance._getSource = source
	instance._getDest = dest
	instance.setup()
	instance.hide()
	
	return instance

func setup() -> void:
	color = Color(1.0, 0.25, 0.05, 0.5)
	top_level = true
	z_as_relative = false
	z_index = 1
	
	halfAngle = rad_to_deg(warningAngleDegrees) * 0.5
	constructCone()
	global_position = _getSource.call().global_position

func constructCone() -> void:
	var points = PackedVector2Array([Vector2.ZERO])
	for i in range(NUM_SEGMENTS + 1):
		var angle := lerpf(-halfAngle, halfAngle, float(i) / NUM_SEGMENTS)
		points.append(Vector2.from_angle(angle) * WARNING_CONE_LENGTH)
	polygon = points

func _physics_process(delta: float) -> void:
	var _source = _getSource.call()
	var _player = _getDest.call()
	
	if not is_instance_valid(_source) or not is_instance_valid(_player):
		return
	
	aimAngle = (
		_player.global_position - _source.global_position
	).angle()
	
	global_rotation = aimAngle
