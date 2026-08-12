extends Area2D
enum ORIENTATION {NORTH, SOUTH, EAST, WEST}
signal requestChangeRoom(room)

## Location of the Boundary within the Room
@export var location : ORIENTATION

var direction = { 
	ORIENTATION.WEST: Vector2.LEFT,
	ORIENTATION.EAST: Vector2.RIGHT,
	ORIENTATION.NORTH: Vector2.UP,
	ORIENTATION.SOUTH: Vector2.DOWN,
}[location] 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return 
		
	var offset := body.global_position - global_position
	var is_valid_entry := false
	
	match location:
		ORIENTATION.WEST:
			is_valid_entry = body.global_position.x > global_position.x
		ORIENTATION.EAST:
			is_valid_entry = body.global_position.x < global_position.x
		ORIENTATION.NORTH:
			is_valid_entry = body.global_position.y > global_position.y
		ORIENTATION.SOUTH:
			is_valid_entry = body.global_position.y < global_position.y

	if is_valid_entry:
		requestChangeRoom.emit(location)
