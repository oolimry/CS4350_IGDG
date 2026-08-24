class_name RoomEntry
extends Area2D

signal requestChangeRoom(direction : ORIENTATION)

## Direction at which the player is entering the room[br]
## Should be opposite of the boundary location
enum ORIENTATION {NORTH, SOUTH, EAST, WEST}

## Location of the Boundary within the Room
@export var location : ORIENTATION

const roomCenter := Vector2i(960, 540)

var playerBody : Node2D
var oriPlayerPos : Vector2

func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return 
	
	playerBody = body
	oriPlayerPos = body.global_position 

func _on_body_exited(body: Node2D) -> void:
	if !is_instance_valid(playerBody) or !is_same(body, playerBody) or !oriPlayerPos.is_finite():
		return
	
	var offset := body.global_position - global_position
	var is_valid_entry := false
	
	match location:
		ORIENTATION.WEST:
			is_valid_entry = oriPlayerPos.x < global_position.x and body.global_position.x > oriPlayerPos.x
		ORIENTATION.EAST:
			is_valid_entry = oriPlayerPos.x > global_position.x and body.global_position.x < oriPlayerPos.x
		ORIENTATION.NORTH:
			is_valid_entry = oriPlayerPos.y < global_position.y and body.global_position.y > oriPlayerPos.y
		ORIENTATION.SOUTH:
			is_valid_entry = oriPlayerPos.y > global_position.y and body.global_position.y < oriPlayerPos.y

	if is_valid_entry:
		requestChangeRoom.emit(location)

	playerBody = null
	oriPlayerPos = Vector2.INF
