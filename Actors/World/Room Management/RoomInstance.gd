class_name RoomInstance
extends Node2D

var roomPos : Vector2i

var roomEntry : RoomEntry

@export var roomResidentsHolder : Node2D

var snapshotDict : Dictionary[StringName, Dictionary]

var isSafeToFreeRoom := true
signal isSafeToFreeRoomUpdate(roomPos : Vector2i, safety: bool)

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
		
		rr.isSafeToFreeUpdate.connect(isSafeToFreeSelfCheck)
		# Objects that always reset to their original state should return
		# back to this original room at their original pos & state.
		if rr.shouldAlwaysReset and n.has_method("generateObjectSnapshot"):
			snapshotDict[rr.persistentID] = n.generateObjectSnapshot()

func forInteractables(c : Callable) -> void:
	for n in get_children():
		c.call(n)
		
########################## Snapshot Related ##################################

func generateRoomSnapshot() -> Dictionary[StringName, Dictionary]:
	if roomResidentsHolder == null:
		return {}
	
	for n in roomResidentsHolder.get_children():
		# We assume all nodes under this Holder have a roomResident object
		assert(n.has_method("generateObjectSnapshot"))
		snapshotDict.get_or_add(n.roomResident.persistentID, 
			n.generateObjectSnapshot())
		
	return snapshotDict

func restoreSnapshot(objectInstantiator : Callable, roomSnapshot: Dictionary) -> void:
	var persistentIDs : Dictionary[StringName, Node] = {}
	if roomResidentsHolder == null:
		return

	for n in roomResidentsHolder.get_children():
		var rr : RoomResident = n.roomResident
		persistentIDs[rr.persistentID] = n
			
	for object in roomSnapshot.keys():
		var objectInstance = objectInstantiator.call(roomSnapshot[object])
		roomResidentsHolder.add_child(objectInstance)
		persistentIDs.erase(roomSnapshot[object]["roomResident"].persistentID)
	
	for n in persistentIDs.values():
		n.queue_free()
		
	persistentIDs.clear()

func isSafeToFree() -> bool:
	for n in roomResidentsHolder.get_children():
		var rr : RoomResident = n.roomResident
		assert(rr != null)
		
		if rr.shouldAlwaysReset:
			continue
		
		if !rr.isSafeToFree:
			return false
	return true
	
func isSafeToFreeSelfCheck(rr : RoomResident, safety : bool) -> void:
	
	# If it was safe to free previously but now isn't
	if !safety and isSafeToFreeRoom:
		isSafeToFreeRoom = false
		isSafeToFreeRoomUpdate.emit(self, false)
		return 
		
	# If it wasn't safe to free previously but now is	
	if safety and !isSafeToFreeRoom and isSafeToFree():
		isSafeToFreeRoomUpdate.emit(self, true)
	
