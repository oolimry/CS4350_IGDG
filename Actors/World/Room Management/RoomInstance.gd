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
		
	setupRoomResidents.call_deferred()

func setupRoomResidents() -> void:
	for n in roomResidentsHolder.get_children():
		var rr : RoomResident = n.roomResident
		assert(rr != null)
		
		rr.isSafeToFreeUpdate.connect(isSafeToFreeSelfCheck)
		
		# TODO: Check if this works as intended
		# Ensure that the oriRoomPos of a object moved into a new Room
		# is not wrongly overwritten
		if rr.oriRoomPos == null:
			rr.oriRoomPos = roomPos
			
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
		snapshotDict[n.roomResident.persistentID] = n.generateObjectSnapshot()
		
	return snapshotDict

func restoreSnapshot(objectInstantiator : Callable, roomSnapshot: Dictionary) -> void:
	var persistentIDstoRemove : Dictionary[StringName, Node] = {}
	var objectsToAdd : Array[Node] = []
	if roomResidentsHolder == null:
		return

	for n in roomResidentsHolder.get_children():
		var rr : RoomResident = n.roomResident
		persistentIDstoRemove[rr.persistentID] = n

	# TODO: Check if instance already exists, whether need to re-update the positioning
	# Do not re-instantiate something already instantiated but like moved 			
	for object in roomSnapshot.keys():
		var objDict : Dictionary = roomSnapshot[object]
		
		var roomResident : RoomResident = objDict["roomResident"]
		
		# If the object state is not considered to be changed, 
		# re-use the placed-in-editor, no need to duplicate instantiate
		if objDict.has("hasStateChanged") and !objDict["hasStateChanged"]:
			persistentIDstoRemove.erase(roomSnapshot[object]["roomResident"].persistentID)
			continue
			
		# Else create a new object and queue it to be added
		var objectInstance = objectInstantiator.call(roomSnapshot[object])
		objectsToAdd.append(objectInstance)
	
	# If the object was present previously in the scene, but was not captured in snapshot
	# Assume its been moved/destroyed and queue the placed-in-editor copy out
	for n in persistentIDstoRemove.values():
		n.queue_free()
		
	for n in objectsToAdd:
		add_child(n)
		
	persistentIDstoRemove.clear()

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
	
