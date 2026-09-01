class_name RoomEntry
extends Area2D

## Time needed past the threshold
@export var requiredDwellTime: float = 1.0

@export var roomPos : Vector2i

signal playerChangeRoom(entryPoint : RoomEntry, roomPos : Vector2i)
signal objectChangeRoom(object : Node2D, roomPos : Vector2i)

## If the player proceeds far enough into the room (they used wind charge and
## fly past the outer detection, use a deeper area2d to detect[br]
## and count them as having enetered
@export var deeperArea: Area2D 

## Ignore entry detection if player respawns back inside the room
@export var isActive := true :
	set(bool) :
		monitoring = isActive
		deeperArea.monitoring = isActive

var enteringObjects : Dictionary[Node, SceneTreeTimer]

func _ready() -> void:
	body_entered.connect(_on_outer_body_entered)
	body_exited.connect(_on_outer_body_exited)
	if deeperArea:
		deeperArea.body_entered.connect(_on_deep_checkpoint_entered)

func _on_outer_body_entered(body: Node2D) -> void:	
	
	# If you don't use a depth checkpoint, use a strict timer for full body clearance
	var entryTimer = get_tree().create_timer(requiredDwellTime)
	entryTimer.timeout.connect(_on_dwell_timeout.bind(body))

	enteringObjects[body] = entryTimer
	Glogger.debug("Outer")
	Glogger.debug(body)
	Glogger.debug(roomPos)


func _on_outer_body_exited(body: Node2D) -> void:
	# The player reached deep into the room! Cancel the timer and confirm entry immediately.
	if enteringObjects.has(body):
		_cancel_entry(body, "Player left before fully entering.")

func _on_deep_checkpoint_entered(body: Node2D) -> void:
	# The player reached deep into the room! Cancel the timer and confirm entry immediately.
	Glogger.debug("Inner")
	_confirm_room_entry(body)

func _on_dwell_timeout(body: Node2D) -> void:
	# If the timer finishes and they haven't left, check if they are still inside
	if !enteringObjects.has(body):
		return
		
	if overlaps_body(body):
		_confirm_room_entry(body)
	else:
		_cancel_entry(body, "Dwell timeout expired, but player was not inside.")

func _confirm_room_entry(body: Node2D) -> void:		
	if enteringObjects.has(body):
		enteringObjects.erase(body) # Effectively stops/invalidates the timer if needed
	
	Glogger.debug("Room fully entered!")
	Glogger.debug(body)
	Glogger.debug(roomPos)
	
	if body is Player:
		playerChangeRoom.emit(self, roomPos)
	else:
		objectChangeRoom.emit(body, roomPos)
		
func _cancel_entry(body: Node2D, reason: String) -> void:
	enteringObjects.erase(body)
	Glogger.debug("Entry canceled: ")
	Glogger.debug(reason)
	Glogger.debug(roomPos)
	

func getRoomPos()-> Vector2i:
	return roomPos 
