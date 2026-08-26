class_name HUDManager
extends CanvasLayer

var getPlayerFunc : Callable

var healthbar : HealthBar
var debugConsole : DebugConsole

# Static factory function acting as a custom constructor
@warning_ignore("shadowed_variable")
static func create(getPlayerFunc : Callable) -> HUDManager:
	## Load in HeartGUI
	var scene = load("uid://yvy353i67sv0") as PackedScene
	var instance = scene.instantiate() as HUDManager

	instance.initUI(getPlayerFunc.call())
	instance.getPlayerFunc = getPlayerFunc
	
	return instance

func initUI(p : Player) -> void:
	var healthBarinstance : HealthBar = HealthBar.create(p.health)
	healthbar = healthBarinstance
	add_child(healthBarinstance)
	
	var debugConsoleInstance : DebugConsole = DebugConsole.create()
	debugConsole = debugConsoleInstance
	add_child(debugConsoleInstance)

func connectUI(p : Player) -> void:
	healthbar.registerPlayer(p.health)
	debugConsole.registerPlayer(p)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("debugConsole"):
		var player : Player = getPlayerFunc.call()
		var newIsDebugOpen = not debugConsole.visible
		debugConsole.visible = newIsDebugOpen
		if newIsDebugOpen:
			debugConsole.grab_focus()
