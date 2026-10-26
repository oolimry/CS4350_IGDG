@tool
class_name Crown
extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D 
@onready var sprite : AnimatedSprite2D = $Sprite
@export var unique_id: String = ""

@export var crown : Enums.Elements:
	set(value):
		crown = value
		setCrownSprite(value)

func _ready() -> void:
	if unique_id != "" and CollectibleManager.is_item_collected(unique_id):
		self.queue_free()
		return
		
	setCrownSprite(crown)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if unique_id != "":
			CollectibleManager.collect_item(unique_id)

		self.queue_free()
		
		
func setCrownSprite(value : Enums.Elements) -> void:	
	if is_instance_valid($Sprite):
		if value == Enums.Elements.WIND:
			$Sprite.play("Wind")
		elif value == Enums.Elements.FIRE:
			$Sprite.play("Fire")
		elif value == Enums.Elements.PURPLE:
			$Sprite.play("Purple")


func _on_area_entered(area: Area2D) -> void:
	if area is WindShockwaveHitbox:
		if unique_id != "":
			CollectibleManager.collect_item(unique_id)
		
		self.queue_free()
		
