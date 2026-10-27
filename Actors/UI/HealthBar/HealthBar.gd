class_name HealthBar
extends HBoxContainer

@export var crownDisplays : Array[TextureRect]

const loseCrownOpacity := 0.25
const gainCrownOpacity := 0.85

## Reference Heart Pointer when healing / being damaged
var currHealth : int

# Static factory function acting as a custom constructor
static func create(ph: Health) -> HealthBar:
	var scene = load("uid://dhjniepaue6n3") as PackedScene
	var instance = scene.instantiate() as HealthBar
	instance.initCrowns(ph.maxHealth, ph.maxHealth)
	instance.registerPlayer(ph)
	
	CollectibleManager.collected.connect(instance.addCrownDisplay)
	
	return instance

func initCrowns(maxHealth : int, cHealth : int = maxHealth):
	currHealth = cHealth
		
func healCrowns(newHealth : int) -> void:
	var prevHealth = currHealth

	updateCrowns(newHealth)

func damageCrowns(newHealth : int) -> void:
	var prevHealth = currHealth

	updateCrowns(newHealth)
	return

func updateCrowns(newHealth : int) -> void:
	currHealth = newHealth
		
	var lenOfDisplay = crownDisplays.size()
	var crownDisplayUpdateIndex = newHealth - 1
	
	for i in range(lenOfDisplay):
		if i >= crownDisplayUpdateIndex:
			crownDisplays[i].self_modulate.a = loseCrownOpacity
		else:
			crownDisplays[i].self_modulate.a = gainCrownOpacity

func addCrownDisplay(crownID : StringName, crownTexture : Texture) -> void:
	var crownTextureRect = TextureRect.new()
	crownTextureRect.texture = crownTexture
	crownDisplays.append(crownTextureRect)
	add_child(crownTextureRect)
	show()

func registerPlayer(ph: Health) -> void:
	ph.hurt.connect(damageCrowns)
	ph.receiveHealing.connect(healCrowns)
	#healCrowns(ph.maxHealth)
