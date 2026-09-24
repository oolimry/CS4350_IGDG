class_name HealthBar
extends HBoxContainer

@export var heartGuiScene : PackedScene
var heartArray : Array[Node]

## Reference Heart Pointer when healing / being damaged
var currHealth : int

# Static factory function acting as a custom constructor
static func create(ph: Health) -> HealthBar:
	## Load in HeartGUI
	var scene = load("uid://dhjniepaue6n3") as PackedScene
	var instance = scene.instantiate() as HealthBar
	instance.initHearts(ph.maxHealth, ph.maxHealth)
	instance.registerPlayer(ph)
	
	return instance

@warning_ignore("shadowed_variable")
func initHearts(maxHealth : int, cHealth : int):
	var heart
	for i in range(maxHealth):
		heart = heartGuiScene.instantiate()
		heartArray.append(heart)
		add_child(heart)
	self.currHealth = cHealth
		
func healHearts(newHealth : int) -> void:
	var prevHealth = currHealth
	currHealth = newHealth
	for i in range(prevHealth, currHealth):
		heartArray[i].healHeart()
	
func damageHearts(newHealth : int) -> void:
	var prevHealth = currHealth
	currHealth = newHealth
	for i in range(prevHealth - 1, currHealth - 1, -1):
		heartArray[i].dmgHeart()
		
	return

func fillAllHearts(maxHealth :int) -> void:
	healHearts(maxHealth)

func registerPlayer(ph: Health) -> void:
	ph.hurt.connect(damageHearts)
	ph.receiveHealing.connect(healHearts)
	fillAllHearts(ph.maxHealth)
