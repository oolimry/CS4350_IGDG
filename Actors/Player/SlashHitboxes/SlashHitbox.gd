class_name SlashHitbox
extends Area2D

@export var slashDirection : Enums.Directions

@export var hitboxActiveDuration = 0.20
@onready var collisionShape = $CollisionShape2D

var player : Player
var globalPositionToFreezeAtDuringSlash = Vector2(0,0)
var originalPosition = Vector2(0,0)

func appear(playerReference : Player):
	player = playerReference
	originalPosition = self.position
	globalPositionToFreezeAtDuringSlash = self.global_position
	
	$AnimationPlayer.play("Slash")
	
	monitoring = true
	monitorable = true
	collisionShape.visible = true
	
	await get_tree().create_timer(hitboxActiveDuration).timeout
	
	monitoring = false
	monitorable = false
	collisionShape.visible = false
	
	player.slashDirection = Enums.Directions.NONE
	position = originalPosition

func _physics_process(delta):
	if not monitoring:
		return
	
	self.global_position = globalPositionToFreezeAtDuringSlash
	var element : Enums.Elements = player.currentElement
	
	#Glogger.debug(get_overlapping_bodies())
	for body : Node2D in get_overlapping_bodies():
		if body.has_method(ScriptConstants.ON_SLASH_METHOD_NAME):
			
			var slashParams : Dictionary = {}
			
			slashParams[ScriptConstants.SLASH_DIRECTION_PARAM_NAME] = self.slashDirection
			slashParams[ScriptConstants.SLASH_ELEMENT_PARAM_NAME] = element
			## TODO: add more info about slash direction, 
			
			body.call(ScriptConstants.ON_SLASH_METHOD_NAME, slashParams, player)
	

	
	
