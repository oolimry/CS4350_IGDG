# Controls how the 
class_name Health
extends Node

@export var maxHealth := 1
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
		hurt.emit(currHealth)
		
	return true

func heal(i : int) -> bool:
	if currHealth >= maxHealth:
		return false
	
	currHealth = min(maxHealth, currHealth + i)
	receiveHealing.emit(currHealth)
	return true

func fullHeal() -> void:
	currHealth = maxHealth
	receiveHealing.emit(currHealth)

func wouldKill(i : int) -> bool:
	if currHealth - i <= 0:
		return true
	return false
