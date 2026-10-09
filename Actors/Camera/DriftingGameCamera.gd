class_name DriftingGameCamera
extends GameCamera

@export var followSpeed: float = 0.6
@export var follow_distance := 100.0

@export var outer_radii : Vector2

var inner_scale := Vector2(0.2, 0.4)
var n 

# How much the camera will follow the player in a static room
var driftVector : Vector2 = Vector2((RoomDefinition.previewBounds.size[0] * 3) / 7 \
	, (RoomDefinition.previewBounds.size[1] * 4)/ 12)

func _ready() -> void:
	outer_radii = driftVector
	n = DebugDrawNode.new(outer_radii, inner_scale)
	get_parent().add_child(n)
	n.z_index = -1
	z_index = -2

func _draw() -> void:
	draw_circle(position, 10.0, Color.BLUE, true)
	queue_redraw()

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
		
		if global_position.distance_squared_to(player.global_position) > 1.0:
			var weight := 1.0 - exp(-followSpeed * delta)
			global_position = global_position.lerp(clamp_to_inner(player.global_position), weight)	
		else:
			global_position = player.global_position
	elif !isSliding:
		var displacement := player.global_position - slideDest
		
		var outside_outer_x := absf(displacement.x) > outer_radii.x
		var outside_outer_y := absf(displacement.y) > outer_radii.y

		var target := slideDest
		if outside_outer_x:
			target.x = player.global_position.x \
				- displacement.normalized().x * follow_distance
		
		if outside_outer_y:
			target.y = player.global_position.y \
				- displacement.normalized().y * follow_distance		
				
		var weight := 1.0 - exp(-followSpeed * delta)
		global_position = global_position.lerp(clamp_to_inner(target), weight)
	pass

func setFullLimit(tlb : Vector2, brb : Vector2, roomDef : RoomDefinition) -> void:
	topLeftBound = tlb
	bottomRightBound = brb
	currentRoom = roomDef

	limit_top = -10000000
	limit_bottom = 10000000
	limit_left = -10000000
	limit_right = 10000000

	limit_enabled = true
	var limitsOverride = ~currentRoom.openSides
	limitsOverride |= currentRoom.cameraLimits
	if limitsOverride & RoomDefinition.Side.TOP:
		limit_top = topLeftBound.y
		
	if limitsOverride & RoomDefinition.Side.BOTTOM:
		limit_bottom = bottomRightBound.y
	
	if limitsOverride & RoomDefinition.Side.LEFT:
		limit_left = topLeftBound.x
	
	if limitsOverride & RoomDefinition.Side.RIGHT:
		limit_right = bottomRightBound.x

func clamp_to_inner(point: Vector2) -> Vector2:
	var displacement := point - slideDest
	var inner_radii := outer_radii * inner_scale
	var distance := (displacement / inner_radii).length()

	return slideDest + displacement / maxf(1.0, distance)
	
	
