extends Node2D

@onready var mainMenu : MainMenu = $MainMenuLayer/MainMenu
@onready var introCutscene = $IntroCutscene

func _ready():
	mainMenu.startButton.pressed.connect(startButtonPressed)

func startButtonPressed():
	mainMenu.visible = false
	introCutscene.visible = true
	
	introCutscene.startCutscene()
