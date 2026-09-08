class_name RoomInstance
extends Node2D

var roomPos : Vector2i

var roomEntry : RoomEntry

@export var roomResidentsHolder : Node2D

var snapshotDict : Dictionary[StringName, Dictionary]

var isSafeToFreeRoom := true
signal isSafeToFreeRoomUpdate(roomPos : Vector2i, safety: bool)

func setup(pos : Vector2i, restoreSnapshot : Callable, isFirstLoad : bool) -> void:
	roomPos = pos
	
	for n in get_children():
		if n is RoomEntry:
			roomEntry = n
			roomEntry.roomPos = roomPos
			
	roomResidentsHolder = get_node("RoomResidents")
	
	# If this room works with roomResidents
	if roomResidentsHolder == null:
		return
		
	setupRoomResidents(isFirstLoad)

	restoreSnapshot.call()

func setupRoomResidents(isFirstLoad : bool) -> void:
	for n in roomResidentsHolder.get_children():
		var rr : RoomResident = n.roomResident
		assert(rr != null)
		
		rr.isSafeToFreeUpdate.connect(isSafeToFreeSelfCheck)
		
		# TODO: Check if this works as intended
		# Ensure that the oriRoomPos of a object moved into a new Room
		# is not wrongly overwritten
		if isFirstLoad:
			rr.oriRoomPos = roomPos
		
		rr.currRoomPos = roomPos
		# AT THE START, objects that always reset to their original state 
		# should return back to this original room at their original pos & state.
		#if rr.shouldAlwaysResetRoom and n.has_method("generateObjectSnapshot"):
			#snapshotDict[rr.persistentID] = n.generateObjectSnapshot()

func forInteractables(c : Callable) -> void:
	for n in get_children():
		c.call(n)
		
########################## Snapshot Related ##################################

func generateRoomSnapshot() -> Dictionary[StringName, Dictionary]:
	if roomResidentsHolder == null:
		return {}
	
	for n in roomResidentsHolder.get_children():
		# We assume all nodes under this Holder have a roomResident object
		# and associated functions.
		#
		# I would have made an interface to enforce but we are using GDScript :<
		assert(n.has_method("generateObjectSnapshot"))
		assert(n.has_method("hasStateChanged"))
		var rr : RoomResident = n.roomResident
		
		# Edge case: Outsider that is supposed to always reset to their original
		# room. Don't bother snapshoting.
		if rr.shouldAlwaysReset and rr.hasRoomChanged():
			continue

		snapshotDict[n.roomResident.persistentID] = n.generateObjectSnapshot()
		
	return snapshotDict

func restoreSnapshot(objectInstantiator : Callable, roomSnapshot: Dictionary) -> void:
	var persistentIDsToRemove : Dictionary[StringName, Node] = {}
	var objectsToAdd : Array[Node] = []
	if roomResidentsHolder == null:
		return

	for n in roomResidentsHolder.get_children():
		var rr : RoomResident = n.roomResident
		persistentIDsToRemove[rr.persistentID] = n

	for object in roomSnapshot.keys():
		var objDict : Dictionary = roomSnapshot[object]
		
		var roomResident : RoomResident = objDict["roomResident"]
		
		# Mark an editor-placed object to NOT be deleted 
		if !(objDict.has("hasStateChanged") and objDict["hasStateChanged"]):
			persistentIDsToRemove[roomSnapshot[object]["roomResident"].persistentID]\
				.roomResident.oriRoomPos = roomResident.oriRoomPos 
			
			persistentIDsToRemove.erase(roomSnapshot[object]["roomResident"].persistentID)
			continue

		var objectInstance = objectInstantiator.call(roomSnapshot[object])
		objectsToAdd.append(objectInstance)
	
	# If the object was present previously in the scene, but was not captured in snapshot
	# Assume its been moved/destroyed and queue the placed-in-editor copy out
	for n in persistentIDsToRemove.values():
		if !n.roomResident.shouldAlwaysReset:
			n.queue_free()
		
	for n in objectsToAdd:
		add_child(n)
		
	persistentIDsToRemove.clear()

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
	
