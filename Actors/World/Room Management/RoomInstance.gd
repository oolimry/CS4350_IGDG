class_name RoomInstance
extends Node2D

var roomPos : Vector2i

@export var hasPlayerSpawn : bool
@export var playerSpawnPoint : PlayerSpawn

@export var roomEntry : RoomEntry

#@export var roomResidents : Array[]
 
func setup(pos : Vector2i) -> void:
	roomPos = pos
	for n in find_children("*", "", true, false):

		if n is PlayerSpawn:
			playerSpawnPoint = n
			hasPlayerSpawn = true
		elif n is RoomEntry:
			roomEntry = n
			roomEntry.roomPos = roomPos	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
