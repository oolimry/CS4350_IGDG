class_name WorldStateOwner
extends RefCounted

var snapshots : Dictionary[Vector2i, Dictionary] = {}

@export var roomResidentConstructors : Dictionary[StringName, Callable] = \
	{
		Box.objName : Box.constructObjectBySnapshot,
		PlaceholderSlashableObject.objName : PlaceholderSlashableObject.constructObjectBySnapshot
	}

func snapshotRoom(ri : RoomInstance) -> void:
	snapshots[ri.roomPos] = ri.generateRoomSnapshot()

func restoreSnapshot(ri : RoomInstance, hasJustLoaded : bool) -> void:
	var roomPos := ri.roomPos
	if !snapshots.has(roomPos):
		return
	
	if hasJustLoaded:
		ri.restoreSnapshotJustLoaded(instantiateResident, snapshots[roomPos])
	else:
		ri.restoreSnapshotLoaded(instantiateResident, snapshots[roomPos])

func instantiateResident(objectSnapshot : Dictionary) -> Node:
	return roomResidentConstructors[objectSnapshot["objectName"]]\
		.call(objectSnapshot)
