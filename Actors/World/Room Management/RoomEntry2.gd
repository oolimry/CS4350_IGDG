class_name RoomEntry2
extends Area2D

## Time needed past the threshold
@export var required_dwell_time: float = 1.4

## Ignore entry detection if player respawns back inside the room
@export var isActive := true

@export var roomPos : Vector2i

signal requestChangeRoom(entryPoint : RoomEntry, roomPos : Vector2i)

## If the player proceeds far enough into the room (they used wind charge and
## fly past the outer detection, use a deeper area2d to detect[br]
## and count them as having enetered
@export var deeperArea: Area2D 

var isPendingEntry: bool = false
var entryTimer: SceneTreeTimer = null

func _ready() -> void:
	body_entered.connect(_on_outer_body_entered)
	body_exited.connect(_on_outer_body_exited)
	if deeperArea:
		deeperArea.body_entered.connect(_on_deep_checkpoint_entered)

func _on_outer_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	
	isPendingEntry = true
	
	# If you don't use a depth checkpoint, use a strict timer for full body clearance
	entryTimer = get_tree().create_timer(required_dwell_time)
	entryTimer.timeout.connect(_on_dwell_timeout.bind(body))

func _on_outer_body_exited(body: Node2D) -> void:
	if body is not Player:
		return
	
	# If the player leaves before fully committing, cancel entry
	if isPendingEntry:
		_cancel_entry("Player left before fully entering.")

func _on_deep_checkpoint_entered(body: Node2D) -> void:
	if body is not Player:
		return
	
	# The player reached deep into the room! Cancel the timer and confirm entry immediately.
	if entryTimer:
		entryTimer.time_left = 0 # Effectively stops/invalidates the timer if needed
	
	_confirm_room_entry()

func _on_dwell_timeout(body: Node2D) -> void:
	# If the timer finishes and they haven't left, check if they are still inside
	if isPendingEntry and overlaps_body(body):
		_confirm_room_entry()
	else:
		_cancel_entry("Dwell timeout expired, but player was not inside.")

func _confirm_room_entry() -> void:		
	if !isActive:
		_cancel_entry("EntryPoint set to InActive!")
		return
	
	isPendingEntry = false
	Glogger.debug("Room fully entered!")
	requestChangeRoom.emit(self, roomPos)

func _cancel_entry(reason: String) -> void:
	isPendingEntry = false
	Glogger.debug("Entry canceled: ")
	Glogger.debug(reason)

func getRoomPos()-> Vector2i:
	return roomPos 
