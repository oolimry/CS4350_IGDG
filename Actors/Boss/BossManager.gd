class_name BossManager
extends Node

var boss : Boss
var isBossKilled := false
var spawnLocation : Vector2
var placePersistent : Callable

var hudManager : HUDManager

var bHealthbar : BossHealthBar
var currBossUniversalCheckpoint : BossCheckPoint

@export var bossFSM : BossFSM
var getPlayer : Callable

var isCleaningBoss := false

func setup(placePersistentFunc : Callable, hudManagerObj : HUDManager, 
	roomManager : RoomManager, getPlayerFunc : Callable) -> void:
		
	self.placePersistent = placePersistentFunc
	roomManager.playerChangedRoom.connect(checkPlayerStillSeeingBoss)
	self.hudManager = hudManagerObj
	self.getPlayer = getPlayerFunc

func handlePlayerEntry(_playerEntry : StringName) -> void:
	if !is_instance_valid(boss) or isBossKilled or\
		isIntroPlaying or isCleaningBoss:
			
		return

	setupBoss()
	hudManager.add_child(bHealthbar)
	hudManager.hideHealthBar(false)
	currBossUniversalCheckpoint.checkPointReached.emit(
			currBossUniversalCheckpoint
		)
	pass

func setupBoss():
	boss = Boss.create(spawnLocation, getPlayer,
			placePersistent.call_deferred
		)
		
	bHealthbar = BossHealthBar.create(boss.health.maxHealth)
	
	boss.health.hurt.connect(bHealthbar.damage)
	boss.health.death.connect(bHealthbar.death)
	boss.health.death.connect(func(_boss : Boss):
		cleanupBoss(true)
	)
	placePersistent.call_deferred(boss)
	
	boss.start()

func cleanupBoss(hasBeenKilled : bool) -> void:
	if isCleaningBoss:
		return
		
	isCleaningBoss = true
	
	if is_instance_valid(boss) and hasBeenKilled:
		AudioManager.fadeOutMusic()
		boss.animationPlayer.play("died")
		await boss.animationPlayer.animation_finished 
	
	# Separate cuz the await may cause a race condition
	if is_instance_valid(boss):
		boss.cleanup()
		boss = null
		
	if is_instance_valid(bHealthbar):
		bHealthbar.call_deferred("queue_free")
		bHealthbar = null
		
	isBossKilled = isBossKilled or hasBeenKilled
	isCleaningBoss = false

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
	
func checkPlayerStillSeeingBoss(room : RoomDefinition) -> void:
	if boss != null and room.roomGroup != RoomDefinition.BIGROOMGROUP.BOSS:
		cleanupBoss(false)
		
