class_name BossManager
extends Node

var boss : Boss
var isBossKilled := false
var spawnLocation : Vector2
var placePersistent : Callable

var hudManager : HUDManager

var bHealthbar : BossHealthBar
var currBossUniversalCheckpoint : BossCheckPoint
var bProjFirer : BossProjFirer


@export var bossFSM : BossFSM
var getPlayer : Callable

func setup(placePersistentFunc : Callable, hudManagerObj : HUDManager, 
	roomManager : RoomManager, getPlayerFunc : Callable) -> void:
		
	self.placePersistent = placePersistentFunc
	roomManager.playerChangedRoom.connect(checkPlayerStillSeeingBoss)
	self.hudManager = hudManagerObj
	self.getPlayer = getPlayerFunc

func handlePlayerEntry(_playerEntry : StringName) -> void:
	if boss == null and !isBossKilled:		
		bProjFirer.setup(func(n : Node): placePersistent.call_deferred(n))
		setupBoss()
		
		hudManager.add_child(bHealthbar)
		hudManager.showHealthBar()
		currBossUniversalCheckpoint.checkPointReached.emit(
			currBossUniversalCheckpoint
		)
		
	pass

func setupBoss():
	boss = Boss.create(spawnLocation, getPlayer, bProjFirer)
	
	bHealthbar = BossHealthBar.create(boss.health.currHealth, 
		boss.health.maxHealth)
	
	boss.health.hurt.connect(bHealthbar.damage)
	boss.health.death.connect(bHealthbar.death)
	boss.health.death.connect(func(_boss : Boss):
		cleanupBoss(true)
	)
	placePersistent.call_deferred(boss)
	boss.start()

func cleanupBoss(hasBeenKilled : bool) -> void:
	if boss:
		boss.queue_free()
		boss = null
	if bHealthbar:
		bHealthbar.queue_free()
		bHealthbar = null

	isBossKilled = hasBeenKilled

##################### Boss Spawn Trigger setup #######################
func registerBossRoom(_rmDef : RoomDefinition, rmInst : RoomInstance) -> void:
	rmInst.forInteractables(_registerBossRoom)

func _registerBossRoom(c : Node) -> void:
	if c is BossTrigger:
		c.connect("playerEntered", handlePlayerEntry)
	
	if c is BossSpawnPoint:
		spawnLocation = c.global_position
	
	if c is BossCheckPoint and c.isUniversal:
		currBossUniversalCheckpoint = c
	
	if c is BossProjFirer:
		bProjFirer = c

func checkPlayerStillSeeingBoss(room : RoomDefinition) -> void:
	if boss != null and room.roomGroup != RoomDefinition.BIGROOMGROUP.BOSS:
		cleanupBoss(false)
