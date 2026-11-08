class_name BossManager
extends Node

var boss : Boss
var isBossKilled := false
var spawnLocation : Vector2
var placePersistent : Callable

var hudManager : HUDManager

var bHealthbar : BossHealthBar
var currBossUniversalCheckpoint : BossCheckPoint
var cameraPanStart : BossCameraPanStart
var roomManager : RoomManager

@export var bossFSM : BossFSM
@export var moveToBottomDuration := 0.4
@export var bottomHoldDuration := 0.75
@export var upwardPanDuration := 5.0
@export var topHoldDuration := 1.0
@export var returnToPlayerDuration := 1.0
@export var healthBarFadeDuration := 0.5

var getPlayer : Callable
var camera : GameCamera
var hasPlayedBossIntro := false
var isIntroPlaying := false

var isCleaningBoss := false

func setup(placePersistentFunc : Callable, hudManagerObj : HUDManager, 
		roomManager : RoomManager, getPlayerFunc : Callable,
		cameraObj : GameCamera) -> void:
		
	self.placePersistent = placePersistentFunc
	roomManager.playerChangedRoom.connect(checkPlayerStillSeeingBoss)
	self.roomManager = roomManager
	self.hudManager = hudManagerObj
	self.getPlayer = getPlayerFunc
	self.camera = cameraObj

func handlePlayerEntry(_playerEntry : StringName) -> void:
	if is_instance_valid(boss) or isBossKilled or \
		isIntroPlaying or isCleaningBoss:
		return

	setupBoss()
	hudManager.add_child(bHealthbar)
	hudManager.hideHealthBar(false)
	currBossUniversalCheckpoint.checkPointReached.emit(
			currBossUniversalCheckpoint
	)

	if hasPlayedBossIntro:
		await _startBossFight()
		return

	bHealthbar.prepareForIntro()
	hasPlayedBossIntro = true
	isIntroPlaying = true
	await _playBossIntro()

func setupBoss() -> void:
	boss = Boss.create(spawnLocation, getPlayer,
			placePersistent.call_deferred
		)
	boss.process_mode = Node.PROCESS_MODE_DISABLED
		
	bHealthbar = BossHealthBar.create(boss.health.maxHealth)
	
	boss.health.hurt.connect(bHealthbar.damage)
	boss.health.death.connect(bHealthbar.death)
	boss.health.death.connect(func(_boss : Boss):
		cleanupBoss(true)
	)
	placePersistent.call_deferred(boss)

func _playBossIntro() -> void:
	AudioManager.fadeToMusic(AudioManager.BossMusic)
		
	assert(camera != null, "BossManager requires the GameCamera dependency")
	assert(is_instance_valid(cameraPanStart), \
		"RoomBoss1 requires a direct BossCameraPanStart child")

	get_tree().paused = true
	if not boss.is_node_ready():
		await boss.ready

	# Override the camera to pan
	var oriDest = camera.slideDest
	var oriZoom = camera.zoom
	camera.beginPositionOverride()
	await camera.panAndZoomTo(cameraPanStart.global_position, Vector2(0.8, 0.8), moveToBottomDuration)
	await get_tree().create_timer(bottomHoldDuration, true).timeout

	var bossHeadPosition := boss.getHeadGlobalPosition()
	var revealPosition := Vector2(cameraPanStart.global_position.x, bossHeadPosition.y)
	await camera.panTo(revealPosition, upwardPanDuration)
	await get_tree().create_timer(topHoldDuration, true).timeout

	var healthBarTween := bHealthbar.fadeIn(healthBarFadeDuration)
	
	var dest = camera.getDestWithinPlayerCameraLimits(oriDest)
	
	await camera.panAndZoomTo(dest, oriZoom, returnToPlayerDuration)
	if healthBarTween.is_valid() and healthBarTween.is_running():
		await healthBarTween.finished

	camera.endPositionOverride()
	get_tree().paused = false
	isIntroPlaying = false
	
	boss.process_mode = Node.PROCESS_MODE_INHERIT
	boss.start()

func _startBossFight() -> void:
	if not boss.is_node_ready():
		await boss.ready
	boss.process_mode = Node.PROCESS_MODE_INHERIT
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
	
	if !hasBeenKilled:
		AudioManager.fadeToMusic(AudioManager.BGM)
			
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

	if c is BossCameraPanStart:
		cameraPanStart = c
	
	if c is BossCheckPoint and c.isUniversal:
		currBossUniversalCheckpoint = c
	
func checkPlayerStillSeeingBoss(room : RoomDefinition) -> void:
	if boss != null and room.roomGroup != RoomDefinition.BIGROOMGROUP.BOSS:
		cleanupBoss(false)
		
