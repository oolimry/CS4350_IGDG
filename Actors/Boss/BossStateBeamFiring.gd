class_name BossStateBeamFiring
extends BossState

## How often the projectiles should fire in seconds
@export var beamCooldownDuration = 2
var projTimer : Timer

## Duration of the state in seconds
@export var duration := 10
var durationTimer : Timer

var projFirer : BossProjFirer
var bossStaff : BossStaff

var randomizer : RandomNumberGenerator

func setup(getB : Callable, getP : Callable, dependencies : Dictionary) -> void:
	super.setup(getB, getP, dependencies)
	projTimer = dependencies["projTimer"]
	bossStaff = dependencies["bossStaff"]
	projFirer = bossStaff.projFirer
	durationTimer = dependencies["durationTimer"]
	
	randomizer = RandomNumberGenerator.new()
	randomizer.randomize()

func _start() -> void:	
	durationTimer.timeout.connect(_end)
	projTimer.timeout.connect(fireBeam)

	durationTimer.start(duration)
	getBoss.call().get_node("CharacterContainer/Body/BossHead").modulate = Color.SKY_BLUE
	
	bossStaff.gemSprite.self_modulate = Color.ORANGE

	fireBeam()
	pass


func fireBeam() -> void:
	projFirer.fireLazer(getPlayer, func():
		projTimer.start(beamCooldownDuration))

func _end() -> void:
	Glogger.debug("Boss out of ammo :P")
	bossStaff.gemSprite.self_modulate = Color.WHITE
	
	durationTimer.timeout.disconnect(_end)
	projTimer.timeout.disconnect(fireBeam)
	
	durationTimer.stop()
	projTimer.stop()
	transitionTo.emit("Idle")
