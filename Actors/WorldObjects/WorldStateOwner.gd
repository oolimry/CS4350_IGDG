class_name WorldStateOwner
extends RefCounted

var snapshots : Dictionary[Vector2i, Dictionary] = {}

@export var roomResidentConstructors : Dictionary[StringName, Callable] = \
	{
		"Box" : Box.constructObjectBySnapshot
	}

func snapshotRoom(ri : RoomInstance) -> void:
	snapshots[ri.roomPos] = ri.generateRoomSnapshot()

func restoreSnapshot(ri : RoomInstance) -> void:
	ri.restoreSnapshot(instantiateResident, snapshots[ri.roomPos])

func instantiateResident(objectSnapshot : Dictionary) -> Node:
	return roomResidentConstructors[objectSnapshot["objectName"]]\
		.call(objectSnapshot)
