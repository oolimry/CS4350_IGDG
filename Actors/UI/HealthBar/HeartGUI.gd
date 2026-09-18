class_name HeartGUI
extends Panel

@export var heartSprite : Sprite2D

## For each Heart icon, the amount of frames to represent it is hpPerHeart + 1
static var totalFramesPerHeart := 2

func healHeart() -> void:
	heartSprite.frame = 0

func dmgHeart() -> void:
	heartSprite.frame = totalFramesPerHeart
