extends CanvasLayer

const MASTER_BUS = 0
const AUDIO_BUS = 1
const MUSIC_BUS = 2

## put the relevant audios here
@onready var Jump : AudioStreamPlayer = $Movement/Jump
@onready var Die : AudioStreamPlayer = $Movement/Die
@onready var FootstepA : AudioStreamPlayer = $Movement/FootstepA
@onready var FootstepB : AudioStreamPlayer = $Movement/FootstepB

@onready var SlashNeutral : AudioStreamPlayer = $Slashing/SlashNeutral
@onready var WindProjectile : AudioStreamPlayer = $Slashing/WindProjectile

@onready var FireElementStruck : AudioStreamPlayer = $Slashing/FireElementStruck
@onready var WindElementStruck : AudioStreamPlayer = $Slashing/WindElementStruck
@onready var PurpleElementStruck : AudioStreamPlayer = $Slashing/PurpleElementStruck

@onready var ExplodableWallExploded : AudioStreamPlayer = $WorldObjects/ExplodableWallExploded
@onready var IgnitionPadLaunch : AudioStreamPlayer = $WorldObjects/IgnitionPadLaunch
@onready var BombExploded : AudioStreamPlayer = $WorldObjects/BombExploded
@onready var CrateBreak : AudioStreamPlayer = $WorldObjects/CrateBreak
@onready var CrownCollected : AudioStreamPlayer = $WorldObjects/CrownCollected


@onready var Shatter : AudioStreamPlayer = $Cutscene/Shatter
@onready var EntityDialogue : AudioStreamPlayer = $Cutscene/EntityDialogue
@onready var PlayerDialogue : AudioStreamPlayer = $Cutscene/PlayerDialogue

@onready var Lazer : AudioStreamPlayer = $Boss/Lazer


@onready var BGM : AudioStreamPlayer = $Music/BGM
@onready var BossMusic : AudioStreamPlayer = $Music/BossMusic

var originalVolumes = {}

var baseVolumes = {}
const volumeFadeDifference = 50
@onready var firstAudioPlayer : AudioStreamPlayer = BGM

var currentAudioPlayer = null

func _ready():
	
	currentAudioPlayer = firstAudioPlayer
	for audioPlayer : AudioStreamPlayer in [BGM, BossMusic]:
		baseVolumes[audioPlayer] = audioPlayer.volume_db
		
		if audioPlayer == firstAudioPlayer:
			pass
		else:
			audioPlayer.volume_db -= volumeFadeDifference
	

func play(audioPlayer : AudioStreamPlayer, playIfAlreadyPlaying = false):
	if playIfAlreadyPlaying or not isPlaying(audioPlayer):
		audioPlayer.play()

func isPlaying(audioPlayer : AudioStreamPlayer):
	if audioPlayer == null:
		return false
	return audioPlayer.is_playing()

func stop(audioPlayer):
	if audioPlayer != null:
		audioPlayer.stop()


func fadeToMusic(newAudioPlayer : AudioStreamPlayer, duration = 2.50):
	
	if newAudioPlayer == currentAudioPlayer:
		return
	
	
	
	newAudioPlayer.play()
	var tween = create_tween()
	tween.tween_property(currentAudioPlayer, "volume_db", baseVolumes[currentAudioPlayer] - volumeFadeDifference, \
	duration * 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(newAudioPlayer, "volume_db", baseVolumes[newAudioPlayer], \
	duration * 1.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	printt("SWITCHING FROM", currentAudioPlayer, newAudioPlayer)
	
	var oldAudioPlayer = currentAudioPlayer
	currentAudioPlayer = newAudioPlayer
	
	await tween.finished
	oldAudioPlayer.stop()
	
	
	
	
		
func fadeOutMusic():
	get_tree().create_tween().tween_property(BGM, "volume_db", -80, 5.0)
	get_tree().create_tween().tween_property(BossMusic, "volume_db", -80, 5.0)
