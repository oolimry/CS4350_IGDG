class_name HeartGUI
extends Panel

@export var heart : Sprite2D

func healVFX() -> void:
	heart.frame += 1
