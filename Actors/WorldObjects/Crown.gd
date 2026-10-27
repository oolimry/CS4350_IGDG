@tool
class_name Crown
extends Area2D

const objName = "Crown"

@onready var collision_shape: CollisionShape2D = $CollisionShape2D 
@onready var sprite : AnimatedSprite2D = $Sprite
@export var unique_id: StringName = ""

@export var roomResident : RoomResident = null

@export_tool_button("Generate RoomResident Data")
var generate_id_action := setup

@export var crown : Enums.Elements:
	set(value):
		crown = value
		setCrownSprite(value)

func setup() -> void:
	roomResident = RoomResident.setup(objName, position, false)

func _ready() -> void:
	if unique_id != "" and CollectibleManager.is_item_collected(unique_id):
		self.queue_free()
		return
		
	setCrownSprite(crown)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if unique_id != "":
			CollectibleManager.collect_item(unique_id, \
				sprite.sprite_frames.get_frame_texture(sprite.animation, 0))

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
			CollectibleManager.collect_item(unique_id, \
				sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
	)
		
		self.queue_free()
		
static func constructObjectBySnapshot(snapshot : Dictionary, \
	constructHandling : Callable) -> PlaceholderSlashableObject:
	assert(snapshot["objectName"] == objName)
	var scene := load("uid://bq2h5kio7nq23") as PackedScene
	var crown := scene.instantiate() as PlaceholderSlashableObject
	crown.scale = snapshot["localScale"]
	crown.position = snapshot["localCoords"]
	crown.roomResident = snapshot["roomResident"]	
	constructHandling.call(crown)
	return crown
	
func generateObjectSnapshot() -> Dictionary:
	var snapshot := {}
	snapshot["roomResident"] = roomResident
	snapshot["localCoords"] = position
	snapshot["localScale"] = scale
	snapshot["hasStateChanged"] = hasStateChanged()
	snapshot["objectName"] = objName
	return snapshot

func hasStateChanged() -> bool:
	# This is okay because the state change for a Crown
	# is the entire deletion of said Crown.
	return false
