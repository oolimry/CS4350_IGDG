extends CanvasLayer

const MASTER_BUS = 0
const AUDIO_BUS = 1
const MUSIC_BUS = 2

## put the relevant audios here
#@onready var CardPickup = $Card/CardPickup
#@onready var CardPutDown = $Card/CardPutDown

func play(audioPlayer : AudioStreamPlayer, playIfAlreadyPlaying = false):
	if playIfAlreadyPlaying or not isPlaying(audioPlayer):
		audioPlayer.play()
		#printt("Playing Audio", audioPlayer)

func isPlaying(audioPlayer : AudioStreamPlayer):
	if audioPlayer == null:
		return false
	return audioPlayer.is_playing()

func stop(audioPlayer):
	if audioPlayer != null:
		audioPlayer.stop()
