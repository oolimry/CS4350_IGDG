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
