class_name BossManager
extends Node

var boss : Boss
var isBossKilled := false
var spawnLocation : Vector2
var reconnectBoss : Callable

var hudManager : HUDManager

var bHealthbar : BossHealthBar

var currBossUniversalCheckpoint : BossCheckPoint

func setup(reconnectBoss : Callable, 
	hudManager : HUDManager, roomManager : RoomManager) -> void:
		
	self.reconnectBoss = reconnectBoss
	roomManager.playerChangedRoom.connect(checkPlayerStillSeeingBoss)
	self.hudManager = hudManager

func handlePlayerEntry(playerEntry : StringName) -> void:
	if boss == null and !isBossKilled:
		var b = Boss.create(spawnLocation)
		boss = b
		
		bHealthbar = BossHealthBar.create(b.health.currHealth, 
			b.health.maxHealth)
		
		## TODO: replace to set Health
		b.health.hurt.connect(bHealthbar.damage)
		b.health.death.connect(bHealthbar.death)
		b.health.death.connect(func(b : Boss):
			cleanupBoss(true)
		)
		reconnectBoss.call_deferred(b)
		hudManager.add_child(bHealthbar)
		hudManager.showHealthBar()
		currBossUniversalCheckpoint.checkPointReached.emit(
			currBossUniversalCheckpoint
		)
	pass

func cleanupBoss(hasBeenKilled : bool) -> void:
	if boss:
		boss.queue_free()
		boss = null
	if bHealthbar:
		bHealthbar.queue_free()
		bHealthbar = null
	
	
	isBossKilled = hasBeenKilled

##################### Boss Spawn Trigger setup #######################
func registerBossRoom(rmDef : RoomDefinition, rmInst : RoomInstance) -> void:
	rmInst.forInteractables(_registerBossRoom)

func _registerBossRoom(c : Node) -> void:
	if c is BossTrigger:
		c.connect("playerEntered", handlePlayerEntry)
	
	if c is BossSpawnPoint:
		spawnLocation = c.global_position
	
	if c is BossCheckPoint and c.isUniversal:
		currBossUniversalCheckpoint = c

func checkPlayerStillSeeingBoss(room : RoomDefinition) -> void:
	if boss != null and room.roomGroup != RoomDefinition.BIGROOMGROUP.BOSS:
		cleanupBoss(false)
