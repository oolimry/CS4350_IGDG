class_name SlashHitbox
extends Area2D

@export var slashDirection : Enums.Directions

var hitboxActiveDuration = 0.10
@onready var collisionShape = $CollisionShape2D

var player : Player

func appear(playerReference : Player):
	player = playerReference
	
	$AnimationPlayer.play("Slash")
	
	monitoring = true
	monitorable = true
	collisionShape.visible = true
	
	await get_tree().create_timer(hitboxActiveDuration).timeout
	
	monitoring = false
	monitorable = false
	collisionShape.visible = false

func _physics_process(delta):
	if not monitoring:
		return
	
	#Glogger.debug(get_overlapping_bodies())
	for body : Node2D in get_overlapping_bodies():
		if body.has_method(ScriptConstants.ON_SLASH_METHOD_NAME):
			
			var slashParams : Dictionary = {}
			
			slashParams[ScriptConstants.SLASH_DIRECTION_PARAM_NAME] = self.slashDirection
			## TODO: add more info about slash direction, 
			
			body.call(ScriptConstants.ON_SLASH_METHOD_NAME, slashParams, player)
	
	
