class_name RoomInstance
extends Node2D

var roomPos : Vector2i

@export var hasPlayerSpawn : bool
@export var playerSpawnPoint : PlayerSpawn

@export var roomEntry : RoomEntry

var roomResidents : Dictionary[Node2D, ResidentSnapshot]
 
func setup(pos : Vector2i) -> void:
	roomPos = pos
	for n in find_children("*", "", true, false):

		if n is PlayerSpawn:
			playerSpawnPoint = n
			hasPlayerSpawn = true
		elif n is RoomEntry:
			roomEntry = n
			roomEntry.roomPos = roomPos	
		elif n is Node2D and n.is_in_group("Interactable"):
			roomResidents[n as Node2D] = null
	capture_snapshot()

func capture_snapshot() -> void:
	var snapshot := ResidentSnapshot.new()
	var snapshotArray : Array[ResidentSnapshot]
	
	for n in roomResidents.keys():
		# We assume all interactables have a roomResident object
		assert(n.roomResident != null)
	
		snapshot.localPos = to_local(n.global_position)

		if n is RigidBody2D:
			snapshot.linearVelocity = n.linear_velocity
			snapshot.angularVelocity = n.angular_velocity
			snapshot.sleeping = n.sleeping
		
		roomResidents[n] = snapshot
		
	return

func restore_snapshot(snapshot: ResidentSnapshot) -> void:
	for n in roomResidents.keys():
		n.local_position = snapshot.localPos
		
		if n is RigidBody2D:
			n.linear_velocity = snapshot.linearVelocity
			n.angular_velocity = snapshot.angularVelocity
			n.sleeping = snapshot.sleeping
