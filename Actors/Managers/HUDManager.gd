class_name HUDManager
extends CanvasLayer

var getPlayerFunc : Callable

var healthbar : HealthBar

# Static factory function acting as a custom constructor
static func create(getPlayerFunc : Callable) -> HUDManager:
	## Load in HeartGUI
	var scene = load("uid://yvy353i67sv0") as PackedScene
	var instance = scene.instantiate() as HUDManager

	instance.initUI(getPlayerFunc.call())
	instance.connectUI(getPlayerFunc.call())

	return instance

func initUI(p : Player) -> void:
	var instance : HealthBar = HealthBar.create(p.health)
	healthbar = instance
	add_child(instance)	

func connectUI(p : Player) -> void:
	healthbar.registerPlayer(p.health)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
