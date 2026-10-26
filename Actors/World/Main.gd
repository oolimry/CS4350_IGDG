extends Node2D

@onready var mainMenu : MainMenu = $MainMenuLayer/MainMenu
@onready var introCutscene = $IntroCutscene
@onready var outroCutscene = $OutroCutscene

@export var toForceStart = false

func _ready():
	mainMenu.startButton.pressed.connect(startButtonPressed)
	SignalManager.bossDefeated.connect(playOutroCutscene)
	
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

func playOutroCutscene():
	
	GlobalGameState.phaseOfGame = GlobalGameState.PhaseOfGame.CREDITS
	outroCutscene.visible = true
	outroCutscene.startCutscene()
