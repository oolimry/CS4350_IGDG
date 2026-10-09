class_name DriftingGameCamera
extends GameCamera

@export var follow_speed: float = 0.4
@export var follow_distance := 100.0

@export var outer_radii := Vector2(500.0, 300.0)

@export_range(0.01, 0.99) 
var inner_scale := 0.9

var n


# How much the camera will follow the player in a static room
var driftVector : Vector2 = Vector2(RoomDefinition.previewBounds.size[0] / 2 \
	, RoomDefinition.previewBounds.size[1] / 2)

func _ready() -> void:
	outer_radii = driftVector
	n = Node2D.new()
	get_parent().add_child(n)
	#positionSmoothingEnabled = false
	#driftHorizontalEnabled = false
	#driftVerticalEnabled = false

static func create(getPlayerFunc : Callable) -> DriftingGameCamera:
	## Load in HeartGUI
	var scene = load("uid://c3n35en38gwbl") as PackedScene
	var instance = scene.instantiate() as GameCamera
	instance.set_script(load("uid://ch06a20sgqahg"))
	instance.registerPlayerRetriever(getPlayerFunc)

	return instance

func _draw() -> void:
	n.draw_ellipse(slideDest, outer_radii.x, outer_radii.y, Color.RED)
	n.draw_ellipse(slideDest, outer_radii.x * inner_scale, outer_radii.y * inner_scale, Color.GREEN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var player : Player = getPlayerFunc.call()
	if isFollowingPlayer and !isSliding:
		self.global_position = player.global_position
	elif !isSliding:
		var displacement := player.global_position - slideDest
		## Scaling an ellipse by its radii turns it into a unit circle.
		var normalized := displacement / outer_radii
		var distance := normalized.length()
		
		var target := slideDest
		var outside_outer := distance > 1.0

		if outside_outer:
			target = player.global_position \
				- displacement.normalized() * follow_distance

		var weight := 1.0 - exp(-follow_speed * delta)
		global_position = global_position.lerp(clamp_to_inner(target), weight)
	pass

func clamp_to_inner(point: Vector2) -> Vector2:
	var displacement := point - slideDest
	var inner_radii := outer_radii * inner_scale
	var distance := (displacement / inner_radii).length()

	return slideDest + displacement / maxf(1.0, distance)
