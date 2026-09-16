class_name BossHealthBar
extends ProgressBar

@export var damageBar : ProgressBar 
@export var damageEffectTimer : Timer

var health := 0 : set = setHealth

static func create(currHealth: int, maxHealth : int) -> BossHealthBar:
	var scene := load("uid://4teqdk4j5ogj") as PackedScene
	var healthbar := scene.instantiate() as BossHealthBar
	
	healthbar.max_value = maxHealth
	healthbar.value = currHealth
	healthbar.health = currHealth
	healthbar.damageBar.max_value = maxHealth
	healthbar.damageBar.value = currHealth
	
	return healthbar

func setHealth(newHealth : int) -> void:
	var prevHealth = health
	health = min(newHealth, max_value)
	value = newHealth
	
	if health < prevHealth:
		damageEffectTimer.start()
	else:
		damageBar.value = health

## TODO: replace to set Health
func damage(hurtDamage : int) -> void:
	setHealth(health - hurtDamage)

func death(boss : Node) -> void:
	setHealth(0)
	damageEffectTimer.start()
	await damageEffectTimer.timeout
	queue_free()

func _on_timer_timeout() -> void:
	damageBar.value = health
	pass # Replace with function body.
