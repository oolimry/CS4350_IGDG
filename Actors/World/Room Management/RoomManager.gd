extends Node
enum ORIENTATION {NORTH, SOUTH, EAST, WEST}

var direction = { 
	ORIENTATION.WEST: Vector2.LEFT,
	ORIENTATION.EAST: Vector2.RIGHT,
	ORIENTATION.NORTH: Vector2.UP,
	ORIENTATION.SOUTH: Vector2.DOWN,
}

## Double Array of Rooms (representing the whole map) x,y
@export var roomGrid : Array[Array] 

## The direction in which the player is moving room to
var movDirection : Vector2
var movDest : Vector2

@export var camera : Camera2D

## Bunch of Placeholder variables TODO: Delete la
@export var test_boundary : Area2D
@export var test_boundary2 : Area2D
@export var test_boundary3 : Area2D
@export var test_boundary4 : Area2D

var animate_lerp := false

## Current room the player is in
var player_curr_room : Room

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	test_boundary.connect("requestChangeRoom", changeRoom)
	test_boundary2.connect("requestChangeRoom", changeRoom)
	test_boundary3.connect("requestChangeRoom", changeRoom)
	test_boundary4.connect("requestChangeRoom", changeRoom)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta):
	if animate_lerp:
		camera.global_position = camera.global_position.lerp(movDest, delta * 5)
		if camera.global_position == movDest:
			animate_lerp = false

func changeRoom(location : ORIENTATION):
	animate_lerp = true
	movDirection = direction.get(location)
	# TODO: Switch from using camera position as reference to using room position
	var oriCameraPos = camera.global_position
	movDest = movDirection * Vector2(1920,1080) + camera.global_position
	pass
