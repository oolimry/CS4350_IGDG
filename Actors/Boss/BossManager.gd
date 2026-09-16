class_name BossManager
extends Node

var boss : Boss
var spawnLocation : Vector2
var reconnectBoss : Callable

func setup(reconnectBoss : Callable) -> void:
	self.reconnectBoss = reconnectBoss

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
		
		var bHealthbar = BossHealthBar.create(b.health.currHealth, 
			b.health.maxHealth)
		
		## TODO: replace to set Health
		b.health.hurt.connect(bHealthbar.damage)
		b.health.death.connect(bHealthbar.death)

		reconnectBoss.call_deferred(b, bHealthbar)
	pass

func cleanupBoss() -> void:
	boss.queue_free()
	boss = null
