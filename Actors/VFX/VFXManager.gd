class_name VFXManager_class
extends Node2D

@onready var FireElementCollectedVFX = preload("res://Actors/VFX/ElementCollected/FireElementCollectedVFX.tscn")

enum Params {
	PLAYER,
	ROTATE_RANDOMLY,
	SPEED,
	SCALE,
}

func createVFX(vfxScene, pos : Vector2, params : Dictionary = {}):	
	var vfx = vfxScene.instantiate()
	self.add_child(vfx)
	
	if "init" in vfx:
		await vfx.init(pos, params)
		return vfx
	else:
		Glogger.ass(false, "CREATING VFX WITH NO VALID INIT FUNCTION")
