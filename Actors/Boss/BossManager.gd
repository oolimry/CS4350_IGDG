class_name BossManager
extends Node

var boss : Boss
var spawnLocation : Vector2
var reconnectBoss : Callable

func setup(reconnectBoss : Callable) -> void:
	self.reconnectBoss = reconnectBoss

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func registerBossRoom(rmDef : RoomDefinition, rmInst : RoomInstance) -> void:
	rmInst.forInteractables(_registerBossRoom)

func _registerBossRoom(c : Node) -> void:
	if c is BossTrigger:
		c.connect("playerEntered", handlePlayerEntry)
	
	if c is BossSpawnPoint:
		spawnLocation = c.global_position

func handlePlayerEntry(playerEntry : StringName) -> void:
	if boss == null:
		var b = Boss.create(spawnLocation)
		boss = b
		reconnectBoss.call_deferred(b)
	pass

func cleanupBoss() -> void:
	boss.queue_free()
	boss = null
