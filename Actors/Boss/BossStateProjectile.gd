class_name BossStateProjectile
extends BossState

## How often the projectiles should fire in seconds
@export var projectileCooldownDuration = 2
var projTimer : Timer

## Duration of the state in seconds
@export var duration := 10
var durationTimer : Timer

@export var burstCooldownDuration := 2
@export var numBurstProjectiles := 4
var currNumBurstProjectiles := 0

var projFirer : BossProjFirer

func setup(getB : Callable, getP : Callable, dependencies : Dictionary) -> void:
	super.setup(getB, getP, dependencies)
	projTimer = dependencies["projTimer"]
	projFirer = dependencies["projFirer"]
	durationTimer = dependencies["durationTimer"]
	
	durationTimer.timeout.connect(_end)
	projTimer.timeout.connect(burstFireProjectile)

func _start() -> void:
	durationTimer.start(duration)
	burstFireProjectile()
	pass

# This gets run by the FSM 
func _physics_process(delta: float) -> void:
	Glogger.debug(projTimer.wait_time)
	Glogger.debug(projTimer.is_stopped())
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
	var straightMovement := ProjectileMovementStraightLine.new()
	var r := RandomNumberGenerator.new()
	r.randomize()
	var element := r.randi_range(Enums.Elements.NONE, Enums.Elements.size()-1)
	var p := ElementProjectile.create(element, straightMovement)
	projFirer.fireProjectile(p, 0)
	projTimer.start(projectileCooldownDuration)
