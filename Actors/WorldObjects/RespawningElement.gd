@tool
class_name RespawningElement
extends Element

@onready var timer: Timer = $Timer

func _ready():
	timer.timeout.connect(respawnElement)
	
func onSlash(slashParams : Dictionary = {}, player : Player = null):
	if not active:
		return
		
	timer.start()
	super.onSlash(slashParams, player)
	
	if element == Enums.Elements.FIRE:
		VfxManager.createVFX(VfxManager.FireElementCollectedVFX, self.global_position, {
			VFXManager_class.Params.PLAYER : player
		})

func respawnElement() -> void:
	collision_shape.set_deferred("monitoring", true)
	self.visible = true
	active = true
	

	
