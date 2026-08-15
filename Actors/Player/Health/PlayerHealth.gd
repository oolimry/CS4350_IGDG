# Controls how the 
class_name PlayerHealth
extends Node

@export var maxHealth := 6
var currHealth := maxHealth
signal playerDamaged(currHealth)
signal playerDeath()
signal playerHealed(currHealth)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func takeDamage(i : int) -> bool:
	if currHealth <= 0:
		return false
	
	if currHealth - i <= 0:
		currHealth = 0
		playerDeath.emit()
	else: 
		currHealth - i
		playerDamaged.emit(i)
		
	return true

func heal(i : int) -> bool:
	if currHealth >= maxHealth:
		return false
	
	currHealth = maxHealth if currHealth + i >= maxHealth else currHealth + i
	playerHealed.emit(i)
	return true
