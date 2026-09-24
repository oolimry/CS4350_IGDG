class_name BossStateProjectile
extends BossState

## How often the projectiles should fire in seconds
@export var projectileCooldownDuration = 1
var projTimer : Timer

## Duration of the state in seconds
@export var duration := 10
var durationTimer : Timer

@export var burstCooldownDuration := 2
@export var numBurstProjectiles := 4
var currNumBurstProjectiles := 0

var projFirer : BossProjFirer

var straightMovement : ProjectileMovementStraightLine
var randomizer : RandomNumberGenerator

func setup(getB : Callable, getP : Callable, dependencies : Dictionary) -> void:
	super.setup(getB, getP, dependencies)
	projTimer = dependencies["projTimer"]
	projFirer = dependencies["projFirer"]
	durationTimer = dependencies["durationTimer"]
	
	durationTimer.timeout.connect(_end)
	projTimer.timeout.connect(burstFireProjectile)
	
	straightMovement = ProjectileMovementStraightLine.new()
	randomizer = RandomNumberGenerator.new()
	randomizer.randomize()

func _start() -> void:
	durationTimer.start(duration)
	burstFireProjectile()
	
	pass

# This gets run by the FSM 
func _physics_process(delta: float) -> void:
	pass

func burstFireProjectile() -> void:
	fireProjectile()
	currNumBurstProjectiles += 1
	if currNumBurstProjectiles > numBurstProjectiles:
		currNumBurstProjectiles = 0
		projTimer.start(burstCooldownDuration)

func _end() -> void:
	Glogger.debug("Boss out of ammo :P")

func fireProjectile() -> void:
	
	# Randomize Element Projectile
	var element := randomizer.randi_range(Enums.Elements.NONE + 1, Enums.Elements.size()-1)
	var p := ElementProjectile.create(element, straightMovement)
	var rot = projFirer.global_position.angle_to_point(getPlayer.call().global_position)
	rot = rad_to_deg(rot)
	
	projFirer.fireProjectile(p, rot)
	projTimer.start(projectileCooldownDuration)
