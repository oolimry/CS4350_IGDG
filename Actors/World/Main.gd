extends Node2D

@onready var mainMenu : MainMenu = $MainMenuLayer/MainMenu
@onready var settingsMenu
@onready var introCutscene = $IntroCutscene

@export var toForceStart = false

func _ready():
	mainMenu.startButton.pressed.connect(startButtonPressed)
	
	if toForceStart:
		forceStart() ## COMMENT THIS OUT TO NOT START
	
func forceStart():
	mainMenu.visible = false
	introCutscene.visible = false
	GlobalGameState.phaseOfGame = GlobalGameState.PhaseOfGame.GAMEPLAY
	
func startButtonPressed():
	mainMenu.visible = false
	introCutscene.visible = true
	
	introCutscene.startCutscene()
