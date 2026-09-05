class_name ResidentSnapshot
extends RefCounted

## Position local to the RoomInstance 
var localPos: Vector2

var roomResident : RoomResident

## Applicable only to Rigidbody2Ds
var linearVelocity: Vector2
var angularVelocity: float
var sleeping: bool

func _init(gameObj : Node2D, rr : RoomResident):
	roomResident = rr
	localPos = gameObj.position
