class_name DriftingGameCamera
extends GameCamera

@export var followSpeed: float = 0.6
@export var follow_distance := 100.0

@export var outer_radii := Vector2(500.0, 300.0)

@export_range(0.01, 0.99) 
var inner_scale := 0.4
var n 

# How much the camera will follow the player in a static room
var driftVector : Vector2 = Vector2((RoomDefinition.previewBounds.size[0] * 3) / 7 \
	, (RoomDefinition.previewBounds.size[1] * 3)/ 7)

func _ready() -> void:
	outer_radii = driftVector
	n = DebugDrawNode.new(outer_radii, inner_scale)
	get_parent().add_child(n)
	n.z_index = -3

static func create(getPlayerFunc : Callable) -> DriftingGameCamera:
	## Load in HeartGUI
	var scene = load("uid://c3n35en38gwbl") as PackedScene
	var instance = scene.instantiate() as GameCamera
	instance.set_script(load("uid://ch06a20sgqahg"))
	instance.registerPlayerRetriever(getPlayerFunc)

	return instance

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	n.global_position = slideDest
	var player : Player = getPlayerFunc.call()
	if isFollowingPlayer and !isSliding:
		self.global_position = player.global_position
	elif !isSliding:
		var displacement := player.global_position - slideDest
		
		var outside_outer := (
			absf(displacement.x) > outer_radii.x
			or absf(displacement.y) > outer_radii.y
		)

		var target := slideDest

		if outside_outer:
			target = (
				player.global_position
				- displacement.normalized() * follow_distance
			)
		var weight := 1.0 - exp(-followSpeed * delta)
		global_position = global_position.lerp(clamp_to_inner(target), weight)
	pass

func clamp_to_inner(point: Vector2) -> Vector2:
	var displacement := point - slideDest
	var inner_radii := outer_radii * inner_scale
	var distance := (displacement / inner_radii).length()

	return slideDest + displacement / maxf(1.0, distance)
