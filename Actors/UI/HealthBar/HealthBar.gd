class_name HealthBar
extends HBoxContainer

@export var heartGuiScene : PackedScene
var heartArray : Array[Node]

## Reference Heart Pointer when healing / being damaged
var currHeartPointer: int

# Static factory function acting as a custom constructor
static func create(ph: PlayerHealth) -> HealthBar:
	## Load in HeartGUI
	var scene = load("uid://dhjniepaue6n3") as PackedScene
	var instance = scene.instantiate() as HealthBar
	instance.initHearts(ph.maxHealth)
	instance.registerPlayer(ph)
	
	return instance

func initHearts(maxHealth : int):
	var heart
	for i in range(maxHealth / HeartGUI.hpPerHeart):
		heart = heartGuiScene.instantiate()
		heartArray.append(heart)
		add_child(heart)
	currHeartPointer = (maxHealth - 1) / HeartGUI.hpPerHeart
		
func healHearts(i : int) -> void:
	var remainingHealing := i
	
	while remainingHealing != 0 and currHeartPointer <= heartArray.size() - 1:
		remainingHealing = heartArray[currHeartPointer].healHeart(remainingHealing)
		currHeartPointer += 1

	if remainingHealing != 0:
		# Reached max hp, no need to heal anymore
		currHeartPointer = heartArray.size() - 1
		return
	
func damageHearts(i : int) -> void:
	var remainingDamage := i
	
	while remainingDamage != 0 and currHeartPointer >= 0:
		remainingDamage = heartArray[currHeartPointer].dmgHeart(remainingDamage)
		currHeartPointer -= 1

	if remainingDamage != 0:
		# Player is very much dead
		currHeartPointer = 0
		return

func fillAllHearts(maxHealth :int) -> void:
	healHearts(maxHealth)

func registerPlayer(ph: PlayerHealth) -> void:
	ph.playerDamaged.connect(damageHearts)
	ph.playerHealed.connect(healHearts)
	fillAllHearts(ph.maxHealth)
