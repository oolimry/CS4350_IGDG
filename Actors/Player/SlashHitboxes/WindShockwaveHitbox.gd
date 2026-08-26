class_name WindShockwaveHitbox
extends Area2D
@export var slashDirection : Enums.Directions

const hitboxActiveDuration = 0.15
@export var movementSpeed = 1600
@onready var collisionShape = $CollisionShape2D

var player : Player

func _ready():
	monitoring = true
	monitorable = true
	collisionShape.visible = true
	
	self.rotation = get_angle_to(Enums.getVectorOfDirection(slashDirection))
	
	await get_tree().create_timer(hitboxActiveDuration).timeout
	
	monitoring = false
	monitorable = false
	collisionShape.visible = false
	self.queue_free()

func _physics_process(delta):
	if not monitoring:
		return
	
	var element : Enums.Elements = Enums.Elements.NONE
	
	var velocity = movementSpeed * Enums.getVectorOfDirection(self.slashDirection)
	self.position += velocity * delta
	
	#Glogger.debug(get_overlapping_bodies())
	for body : Node2D in get_overlapping_bodies():
		if body.has_method(ScriptConstants.ON_SLASH_METHOD_NAME):
			
			var slashParams : Dictionary = {}
			
			slashParams[ScriptConstants.SLASH_DIRECTION_PARAM_NAME] = self.slashDirection
			slashParams[ScriptConstants.SLASH_ELEMENT_PARAM_NAME] = element
			slashParams[ScriptConstants.WIND_SHOCKWAVE_PARAM_NAME] = true
			## TODO: add more info about slash direction, 
			
			body.call(ScriptConstants.ON_SLASH_METHOD_NAME, slashParams, player)
		
	
	
