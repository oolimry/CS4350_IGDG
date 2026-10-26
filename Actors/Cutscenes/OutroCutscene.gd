extends CanvasLayer

@onready var dialogueFile = preload("res://Actors/Cutscenes/OutroText.dialogue")

@onready var scene1 = $Scene1

@onready var scene2 = $Scene2
@onready var scene2Blackness = $Scene2/Blackness

@onready var whiteFlashAnimationPlayer = $WhiteFlash/AnimationPlayer
var dialogueBox

var ifForceSkip = false

func _ready():	
	CutsceneSignalManager.outroScene1Finished.connect(onScene1Finished)
	CutsceneSignalManager.outroScene2Finished.connect(onScene2Finished)

func startCutscene():
	self.visible = true
	dialogueBox = DialogueManager.show_dialogue_balloon(dialogueFile, "scene1")


func skipCutscene():
	GlobalGameState.phaseOfGame = GlobalGameState.PhaseOfGame.GAMEPLAY
	scene1.visible = false
	scene2.visible = false
	ifForceSkip = true
	$Label.visible = false
	if is_instance_valid(dialogueBox):
		dialogueBox.visible = false
	
func onScene1Finished():
	if ifForceSkip:
		return
	
	whiteFlashAnimationPlayer.play("Flash")
	await whiteFlashAnimationPlayer.animation_finished
	
	scene1.visible = false
	scene2.visible = true
	
	whiteFlashAnimationPlayer.play("BecomeTransparent")
	dialogueBox = DialogueManager.show_dialogue_balloon(dialogueFile, "scene2")
	 
func onScene2Finished():
	if ifForceSkip:
		return
	
	$Credits/AnimationPlayer.play("Credits")
	
func _on_button_pressed():
	get_tree().change_scene_to_file("res://Actors/World/Main.tscn")
