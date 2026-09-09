class_name RoomInstance
extends Node2D

var roomPos : Vector2i

var roomEntry : RoomEntry

@onready var roomResidentsHolder : Node2D = $RoomResidents

var oriRoomResidents : Dictionary[StringName, Dictionary]
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
	
		# If you fail this assert, likely means one of the RoomResident Objects
		# did not have their button pressed	
		assert(rr != null)
		
		rr.isSafeToFreeUpdate.connect(isSafeToFreeSelfCheck)
		
		# TODO: Check if this works as intended
		# Ensure that the oriRoomPos of a object moved into a new Room
		# is not wrongly overwritten
		#if isFirstLoad:
		rr.oriRoomPos = roomPos
		rr.currRoomPos = roomPos
	
		# Setup should always be called when the room is loaded in
		# When it is loaded in, all nodes should be in their original state
		oriRoomResidents[rr.persistentID] = n.generateObjectSnapshot()
		

func forInteractables(c : Callable) -> void:
	for n in get_children():
		c.call(n)
		
########################## Snapshot Related ##################################

func generateRoomSnapshot() -> Dictionary[StringName, Dictionary]:
	if roomResidentsHolder == null:
		return {}
	snapshotDict.clear()
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
		if !rr.isSafeToSnapshot or (rr.shouldAlwaysReset and rr.hasRoomChanged()):
			continue 

		snapshotDict[n.roomResident.persistentID] = n.generateObjectSnapshot()
	
	return snapshotDict

## Restore Snapshot for a Loaded Room[br]
## In this case the roomSnapshot will be under roomResidentHolder will be the same as the
## 
func restoreSnapshotLoaded(objectInstantiator : Callable, roomSnapshot: Dictionary) -> void:
	var instancesToDelete : Dictionary[StringName, Node] = {}
	var objectsToAdd : Array[Node] = []
	
	if roomResidentsHolder == null:
		return
		
	# Grab the actual nodes of the already instantiated nodes
	for n in roomResidentsHolder.get_children():
		var rr : RoomResident = n.roomResident
		instancesToDelete[rr.persistentID] = n

	for id in oriRoomResidents.keys():
		
		if instancesToDelete.has(id):
			# If there's an pre-existing instance of the object that hasn't
			# been state changed, use that. Don't reinitialize a duplicate
			if !instancesToDelete[id].hasStateChanged():

				#instancesToDelete[id].roomResident.oriRoomPos \
					#= oriRoomResident.oriRoomPos
				instancesToDelete.erase(id)
				continue
			
		# Otherwise we need to reinitialize from the original source
		if oriRoomResidents[id]["roomResident"]["shouldAlwaysReset"]:
			objectInstantiator.call(oriRoomResidents[id],
				func(instance : Node2D): objectsToAdd.append(instance))
	
	# These remaining nodes are instances that may have newly moved into 
	# this room or have been changed from their originals
	# we need to check if we should delete em or persist em
	for id in instancesToDelete.keys():
		
		# All those remaining in this list, from the original list 
		# or newly added nodes that shouldAlwaysReset, should be deleted
		if id in oriRoomResidents.keys() or \
			instancesToDelete[id].roomResident.shouldAlwaysReset:
			
			instancesToDelete[id].queue_free()
	
	for n in objectsToAdd:
		roomResidentsHolder.add_child(n)

	
## Restore Snapshot for a Newly Loaded Room[br]
## In this case the children under roomResidentHolder will be the same as the
## oriRoomResidents
func restoreSnapshotJustLoaded(objectInstantiator : Callable, roomSnapshot: Dictionary) -> void:
	var oriNodesToDelete : Dictionary[StringName, Node] = {}
	var objectsToAdd : Array[Node] = []
	if roomResidentsHolder == null:
		return

	for n in roomResidentsHolder.get_children():
		var rr : RoomResident = n.roomResident
		oriNodesToDelete[rr.persistentID] = n
		assert(rr.persistentID in oriRoomResidents.keys())

	assert(oriRoomResidents.size() == oriNodesToDelete.size())

	for id in oriRoomResidents.keys():
		
		# IF object state was not changed OR object should always reset->
		# Reuse the original instantiated object (if it exists)
		if (roomSnapshot.has(id) and !roomSnapshot[id]["hasStateChanged"]) or \
			oriNodesToDelete[id].roomResident.shouldAlwaysReset:
			oriNodesToDelete.erase(id)
			
	for id in roomSnapshot.keys():
		if id in oriNodesToDelete.keys() or \
			(!oriRoomResidents.has(id) and !roomSnapshot[id]["roomResident"]["shouldAlwaysReset"]):
			
				objectInstantiator.call(oriRoomResidents[id],
					func(instance : Node2D): objectsToAdd.append(instance))
	
	for n in oriNodesToDelete:
		oriNodesToDelete[n].queue_free()
	
	for n in objectsToAdd:
		roomResidentsHolder.add_child(n)

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
	
