# Controls how the 
class_name Health
extends Node

@export var maxHealth := 6
var currHealth : int
signal hurt(currHealth)
signal death()
signal receiveHealing(currHealth)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currHealth = maxHealth
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func takeDamage(i : int) -> bool:
		
	if currHealth - i <= 0:
		currHealth = 0
		death.emit(get_parent())
	else: 
		currHealth -= i
		hurt.emit(i)
		
	return true

func heal(i : int) -> bool:
	if currHealth >= maxHealth:
		return false
	
	currHealth = maxHealth if currHealth + i >= maxHealth else currHealth + i
	receiveHealing.emit(i)
	return true


func _on_boss_take_damage(damage: int) -> void:
	takeDamage(damage)
	Glogger.debug("Boss says Ouch!")
	pass # Replace with function body.
