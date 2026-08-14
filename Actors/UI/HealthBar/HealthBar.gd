class_name HealthBar
extends HBoxContainer

@export var HeartGuiClass : PackedScene
var heartArray : Array[Node]

## Reference Heart Pointer when healing / being damaged
var currHeartPointer: int

## How much HP per Heart icon? (Default is 2)
@export var hpPerHeart := 2

func initHearts(maxHealth : int):
	for i in range(maxHealth / hpPerHeart):
		var heart = HeartGuiClass.instantiate()
		heartArray.append(heart)
		add_child(heart)
	currHeartPointer = (maxHealth - 1) / hpPerHeart
		
func healHeart() -> void:
	if currHeartPointer + 1 >= len(heartArray):
		return
	
	heartArray[currHeartPointer + 1].get_node("HeartGUI").healVFX()

# Static factory function acting as a custom constructor
static func create(ph: PlayerHealth) -> HealthBar:
	## Load in HeartGUI
	var scene = load("uid://dhjniepaue6n3") as PackedScene
	var instance = scene.instantiate() as HealthBar
	instance.initHearts(ph.maxHealth)
	
	return instance
