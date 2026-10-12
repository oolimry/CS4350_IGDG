class_name GameCamera
extends Camera2D

# How quickly to move through the noise
@export var NOISE_SHAKE_SPEED: float = 30.0
# Noise returns values in the range (-1, 1)
# So this is how much to multiply the returned value by
@export var NOISE_SHAKE_STRENGTH: float = 60.0
# Multiplier for lerping the shake strength to zero
@export var SHAKE_DECAY_RATE: float = 5.0

@onready var rand = RandomNumberGenerator.new()
@onready var noise = FastNoiseLite.new()

var noise_i: float = 0.0
var shake_strength: float = 0.0
var originalPosition : Vector2

var goodSeeds = []

var getPlayerFunc : Callable

var isFollowingPlayer : bool
var topLeftBound : Vector2
var bottomRightBound : Vector2
var currentRoom : RoomDefinition

var slideDest : Vector2
var isSliding : bool

var isShaking = false

func registerPlayerRetriever(c: Callable):
	getPlayerFunc = c

# Static factory function acting as a custom constructor
static func create(getPlayerFunc : Callable) -> GameCamera:
	## Load in HeartGUI
	var scene = load("uid://c3n35en38gwbl") as PackedScene
	var instance = scene.instantiate() as GameCamera

	instance.registerPlayerRetriever(getPlayerFunc)
	SignalManager.triggerScreenshake.connect(instance.apply_noise_shake)

	return instance

var slide_tween: Tween

# Thanks ChatGPT
func slideTowards(destination : Vector2) -> void:
	isSliding = true
	slideDest = destination

	if slide_tween and slide_tween.is_valid():
		slide_tween.kill()

	slide_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	slide_tween.tween_property(self, "global_position", slideDest, 0.2)
	slide_tween.finished.connect(func(): isSliding = false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if isFollowingPlayer and !isSliding:
		var player : Player = getPlayerFunc.call()
		self.global_position = player.global_position
		setFullLimit(topLeftBound, bottomRightBound, currentRoom)
	
	if isShaking:
		shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
		position = originalPosition + get_noise_offset(delta)
	
		if shake_strength < 0.001:
			isShaking = false
			position = originalPosition

func startFollowingPlayer() -> void:
	isFollowingPlayer = true
	
func setHorizontalLimit(tlb : Vector2, brb : Vector2, roomDef : RoomDefinition):
	topLeftBound = tlb
	bottomRightBound = brb
	currentRoom = roomDef
	
	limit_enabled = true
	if currentRoom.cameraLimits & RoomDefinition.Side.LEFT:
		limit_left = topLeftBound.x
	
	if currentRoom.cameraLimits & RoomDefinition.Side.RIGHT:
		limit_right = bottomRightBound.x
		
	limit_top = -10000000
	limit_bottom = 10000000

	
func setVerticalLimit(tlb : Vector2, brb : Vector2, roomDef : RoomDefinition):
	topLeftBound = tlb
	bottomRightBound = brb
	currentRoom = roomDef
		
	limit_enabled = true
	if currentRoom.cameraLimits & RoomDefinition.Side.TOP:
		limit_top = topLeftBound.y
		
	if currentRoom.cameraLimits & RoomDefinition.Side.BOTTOM:
		limit_bottom = bottomRightBound.y
	
	limit_left = -10000000
	limit_right = 10000000


func setFullLimit(tlb : Vector2, brb : Vector2, roomDef : RoomDefinition) -> void:
	assert(roomDef != null)
	topLeftBound = tlb
	bottomRightBound = brb
	currentRoom = roomDef
	
	limit_enabled = true
	if currentRoom.cameraLimits & RoomDefinition.Side.TOP:
		limit_top = topLeftBound.y
		
	if currentRoom.cameraLimits & RoomDefinition.Side.BOTTOM:
		limit_bottom = bottomRightBound.y
	
	if currentRoom.cameraLimits & RoomDefinition.Side.LEFT:
		limit_left = topLeftBound.x
	
	if currentRoom.cameraLimits & RoomDefinition.Side.RIGHT:
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

func apply_noise_shake() -> void:
	isShaking = true
	originalPosition = self.position
	shake_strength = NOISE_SHAKE_STRENGTH

func get_noise_offset(delta: float) -> Vector2:
	noise_i += delta * NOISE_SHAKE_SPEED
	# Set the x values of each call to 'get_noise_2d' to a different value
	# so that our x and y vectors will be reading from unrelated areas of noise
	return Vector2(
		noise.get_noise_2d(1, noise_i) * shake_strength,
		noise.get_noise_2d(100, noise_i) * shake_strength
	)
