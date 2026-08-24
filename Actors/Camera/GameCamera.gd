class_name GameCamera
extends Camera2D

var getPlayerFunc : Callable

var isFollowingPlayer : bool
var topLeftBound : Vector2
var bottomRightBound : Vector2

var slideDest : Vector2
var isSliding : bool

func registerPlayerRetriever(c: Callable):
	getPlayerFunc = c

# Static factory function acting as a custom constructor
static func create(getPlayerFunc : Callable) -> GameCamera:
	## Load in HeartGUI
	var scene = load("uid://c3n35en38gwbl") as PackedScene
	var instance = scene.instantiate() as GameCamera

	instance.registerPlayerRetriever(getPlayerFunc)

	return instance

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if isFollowingPlayer and !isSliding:
		var player : Player = getPlayerFunc.call()
		self.global_position = player.global_position
		setFullLimit(topLeftBound, bottomRightBound)

	if isSliding:
		global_position = global_position.lerp(slideDest, delta * 5)
		if global_position.is_equal_approx(slideDest):
			isSliding = false
	pass

func startFollowingPlayer() -> void:
	isFollowingPlayer = true
	
func slideTowards(slideDest : Vector2) -> void:
	isSliding = true
	self.slideDest = slideDest
	
func setHorizontalLimit(tlb : Vector2, brb : Vector2):
	topLeftBound = tlb
	bottomRightBound = brb
	
	limit_enabled = true
	limit_left = topLeftBound.x
	limit_right = bottomRightBound.x
	limit_top = -10000000
	limit_bottom = 10000000

	
func setVerticalLimit(tlb : Vector2, brb : Vector2):
	topLeftBound = tlb
	bottomRightBound = brb
	
	limit_enabled = true
	limit_top = topLeftBound.y
	limit_bottom = bottomRightBound.y
	limit_left = -10000000
	limit_right = 10000000


func setFullLimit(tlb : Vector2, brb : Vector2) -> void:
	topLeftBound = tlb
	bottomRightBound = brb
	
	limit_enabled = true
	limit_top = topLeftBound.y
	limit_bottom = bottomRightBound.y
	limit_left = topLeftBound.x
	limit_right = bottomRightBound.x

func stopFollowing() -> void:
	isFollowingPlayer = false
	global_position = get_screen_center_position()
	limit_left = -10000000
	limit_top = -10000000
	limit_right = 10000000
	limit_bottom = 10000000
	limit_enabled = false
	
	self.topLeftBound = Vector2(-10000000, -10000000)
	self.bottomRightBound = Vector2(-10000000, -10000000)
