class_name BossStateProjectileShooting
extends BossState

@export var projectileDelayDuration = 1.2
var delayTimer : Timer

## How often the projectiles should fire in seconds
@export var projectileCooldownDuration = 0.5
var projTimer : Timer

## Duration of the state in seconds
@export var duration := 10
var durationTimer : Timer

@export var burstCooldownDuration := 2
@export var numBurstProjectiles := 4
var currNumBurstProjectiles := 0

var bossStaff : BossStaff
var projFirer : BossProjFirer

var projectileWarning : ProjectileWarning

var straightMovement : ProjectileMovementStraightLine
var randomizer : RandomNumberGenerator

func setup(getB : Callable, getP : Callable, dependencies : Dictionary) -> void:
	super.setup(getB, getP, dependencies)
	projTimer = dependencies["projTimer"]
	bossStaff = dependencies["bossStaff"]
	durationTimer = dependencies["durationTimer"]
	delayTimer = dependencies["delayTimer"]
	
	projFirer = bossStaff.projFirer
	projectileWarning = projFirer.createProjectileWarning(getP)
	
	straightMovement = ProjectileMovementStraightLine.new()
	randomizer = RandomNumberGenerator.new()
	randomizer.randomize()

func _start() -> void:	
	durationTimer.timeout.connect(_end)
	projTimer.timeout.connect(burstFireProjectile)

	durationTimer.start(duration)
	burstFireProjectile()
	bossStaff.gemSprite.self_modulate = Color.REBECCA_PURPLE
	pass

func burstFireProjectile() -> void:
	if currNumBurstProjectiles == 0:
		projectileWarning.show()
		delayTimer.start(projectileDelayDuration)
		projectileWarning.hideWarning()
		await delayTimer.timeout
		
		
	fireProjectile()
	currNumBurstProjectiles += 1
	if currNumBurstProjectiles >= numBurstProjectiles:
		currNumBurstProjectiles = 0
		projTimer.start(burstCooldownDuration)

func _end() -> void:
	Glogger.debug("Boss out of ammo :P")
	bossStaff.gemSprite.self_modulate = Color.WHITE

	durationTimer.timeout.disconnect(_end)
	projTimer.timeout.disconnect(burstFireProjectile)
	
	durationTimer.stop()
	projTimer.stop()
	transitionTo.emit("Idle")

func fireProjectile() -> void:
	
	# Randomize Element Projectile
	var element := randomizer.randi_range(Enums.Elements.NONE + 1, Enums.Elements.size()-1)
	var p := ElementProjectile.create(element, straightMovement)
	var rot = projFirer.global_position.angle_to_point(getPlayer.call().global_position)
	rot = rad_to_deg(rot)
	
	projFirer.fireProjectile(p, rot)
	projTimer.start(projectileCooldownDuration)
