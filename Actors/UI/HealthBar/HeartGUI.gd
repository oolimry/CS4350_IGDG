class_name HeartGUI
extends Panel

@export var heartSprite : Sprite2D

## How much HP per Heart icon? Dependent on Spritework
static var hpPerHeart := 2

## For each Heart icon, the amount of frames to represent it is hpPerHeart + 1
var totalFramesPerHeart := hpPerHeart + 1

func healHeart(i : int) -> int:
	var leftover = i - heartSprite.frame
	
	if leftover <= 0:
		heartSprite.frame -= i
		return 0
	else:
		heartSprite.frame = 0
		return leftover


func dmgHeart(i : int) -> int:
	var leftover = i - (hpPerHeart - heartSprite.frame)
	
	if leftover <= 0:
		heartSprite.frame += i
		return 0
	else:
		heartSprite.frame = totalFramesPerHeart
		return leftover
