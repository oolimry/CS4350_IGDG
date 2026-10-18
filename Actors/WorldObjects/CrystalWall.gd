@tool
class_name CrystalWall
extends StaticBody2D

@onready var killzone : Area2D = $KillZone
@export var hasKillzoneExclusion := false

@export var width : float = 160:
	set(value):
		width = value
		updateVisuals()
	
@export var height : float = 240:
	set(value):
		height = value
		updateVisuals()

func updateVisuals():
	if is_instance_valid($Sprite2D):
		$Sprite2D.size = Vector2(width, height) / $Sprite2D.scale.x
		
	if is_instance_valid($CollisionShape2D):
		$CollisionShape2D.scale = Vector2(width / $CollisionShape2D.shape.size.x, \
			height / $CollisionShape2D.shape.size.y)
		$CollisionShape2D.position = Vector2(width, height) * 0.5
		
	if is_instance_valid($KillZone/CollisionShape2D):
		$KillZone/CollisionShape2D.scale = Vector2(width / $KillZone/CollisionShape2D.shape.size.x, \
			height / $KillZone/CollisionShape2D.shape.size.y)
		$KillZone/CollisionShape2D.position = Vector2(width, height) * 0.5

func _process(delta):
	for body in killzone.get_overlapping_bodies():
		if body is Player:
			if body.isPurpleDashing:
				return
			else:
				if body.velocity == Vector2(0, 0) and !hasKillzoneExclusion:
					body.triggerDeath()
