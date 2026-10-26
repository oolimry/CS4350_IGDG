extends CanvasLayer

@onready var dialogueFile = preload("res://Actors/Cutscenes/IntroText.dialogue")

@onready var scene1 = $Scene1

@onready var scene2 = $Scene2
@onready var scene2Blackness = $Scene2/Blackness

@onready var whiteFlashAnimationPlayer = $WhiteFlash/AnimationPlayer
var dialogueBox

var ifForceSkip = false

func _ready():	
	CutsceneSignalManager.scene1Finished.connect(onScene1Finished)
	CutsceneSignalManager.scene2Finished.connect(onScene2Finished)

func startCutscene():
	AudioManager.play(AudioManager.BGM)
	dialogueBox = DialogueManager.show_dialogue_balloon(dialogueFile, "scene1")


func _process(delta):
	if Input.is_action_pressed("left") and Input.is_action_pressed("jump") and not ifForceSkip:
		skipCutscene()


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
	
	AudioManager.play(AudioManager.Shatter)
	scene1.visible = false
	scene2.visible = true
	
	# a small delay
	await get_tree().create_timer(1.0).timeout
	
	# the black fades out
	var tween = get_tree().create_tween()
	tween.tween_property(scene2Blackness, "modulate:a", 0, 3.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
	dialogueBox = DialogueManager.show_dialogue_balloon(dialogueFile, "scene2")
	 
func onScene2Finished():
	if ifForceSkip:
		return
	
	AudioManager.play(AudioManager.Shatter)	
	whiteFlashAnimationPlayer.play("Flash")
	await whiteFlashAnimationPlayer.animation_finished
	
	scene2.visible = false
	
	GlobalGameState.phaseOfGame = GlobalGameState.PhaseOfGame.GAMEPLAY
	whiteFlashAnimationPlayer.play("BecomeTransparent")
	$Label.visible = false
	
