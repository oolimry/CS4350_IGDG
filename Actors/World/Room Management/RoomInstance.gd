class_name RoomInstance
extends Node2D

var roomPos : Vector2i

@export var hasPlayerSpawn : bool
@export var playerSpawnPoint : PlayerSpawn

@export var roomEntry : RoomEntry

@export var roomResidentsHolder : Node2D

var snapshotDict : Dictionary[StringName, Dictionary]

func setup(pos : Vector2i) -> void:
	roomPos = pos
	for n in get_children():
		if n is RoomEntry:
			roomEntry = n
			roomEntry.roomPos = roomPos
			
	roomResidentsHolder = get_node("RoomResidents")
	
	# If this room works with roomResidents
	if roomResidentsHolder == null:
		return
	
	for n in roomResidentsHolder.get_children():
		var rr : RoomResident = n.roomResident
		assert(rr != null)
		
		# Objects that always reset to their original state should return
		# back to this original room at their original pos & state.
		if !rr.shouldAlwaysReset and n.has_method("generateObjectSnapshot"):
			snapshotDict[rr.persistentID] = n.generateObjectSnapshot()

func forInteractables(c : Callable) -> void:
	for n in get_children():
		c.call(n)
########################## Snapshot Related ##################################

func generateRoomSnapshot() -> Dictionary[StringName, Dictionary]:
	Glogger.debug("Capture!")
	for n in roomResidentsHolder.get_children():
		# We assume all nodes under this Holder have a roomResident object
		assert(n.has_method("generateObjectSnapshot"))
		snapshotDict.get_or_add(n.roomResident.persistentID, 
			n.generateObjectSnapshot())
		
	return snapshotDict

func restoreSnapshot(objectInstantiator : Callable, roomSnapshot: Dictionary) -> void:
	

	Glogger.debug("UnCapture!")
	for object in roomSnapshot.keys():
		var objectInstance = objectInstantiator.call(roomSnapshot[object])
		roomResidentsHolder.add_child(objectInstance)
