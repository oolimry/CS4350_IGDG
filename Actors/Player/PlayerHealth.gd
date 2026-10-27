class_name PlayerHealth
extends Health

func _ready() -> void:
	CollectibleManager.collected.connect(
		func(id : StringName, texture : Texture):
			increaseMaxHealth())

func increaseMaxHealth() -> void:
	maxHealth += 1
	currHealth = maxHealth
	receiveHealing.emit(currHealth)
	
