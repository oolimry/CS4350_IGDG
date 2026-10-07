extends CanvasLayer

@onready var dialogueFile = preload("res://Actors/Cutscenes/IntroText.dialogue")

@onready var scene1 = $Scene1

@onready var scene2 = $Scene2
@onready var scene2Blackness = $Scene2/Blackness

@onready var whiteFlashAnimationPlayer = $WhiteFlash/AnimationPlayer

var ifForceSkip = false

func _ready():
	DialogueManager.show_dialogue_balloon(dialogueFile, "scene1")
	
	CutsceneSignalManager.scene1Finished.connect(onScene1Finished)
	CutsceneSignalManager.scene2Finished.connect(onScene2Finished)

func _process(delta):
	if Input.is_action_pressed("left") and Input.is_action_pressed("jump"):
		GlobalGameState.phaseOfGame = GlobalGameState.PhaseOfGame.GAMEPLAY
		scene1.visible = false
		scene2.visible = false
		ifForceSkip = true
		


func onScene1Finished():
	if ifForceSkip:
		return
		
	scene1.visible = false
	scene2.visible = true
	
	# a small delay
	await get_tree().create_timer(1.0).timeout
	
	Glogger.debug("A")
	
	# the black fades out
	var tween = get_tree().create_tween()
	tween.tween_property(scene2Blackness, "modulate:a", 0, 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	Glogger.debug("B")
	await tween.finished
	Glogger.debug("C")
	DialogueManager.show_dialogue_balloon(dialogueFile, "scene2")
	 
func onScene2Finished():
	if ifForceSkip:
		return
		
	whiteFlashAnimationPlayer.play("Flash")
	await whiteFlashAnimationPlayer.animation_finished
	
	scene2.visible = false
	
	GlobalGameState.phaseOfGame = GlobalGameState.PhaseOfGame.GAMEPLAY
	whiteFlashAnimationPlayer.play("BecomeTransparent")
	
