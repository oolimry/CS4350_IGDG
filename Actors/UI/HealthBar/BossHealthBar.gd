class_name BossHealthBar
extends ProgressBar

const DAMAGE_DRAIN_DURATION := 0.6
const DAMAGE_COLOR := Color("ffc45c")
const FRAME_COLOR := Color("17171c")
const FRAME_BORDER_COLOR := Color("08080b")
const FRAME_CORNER_RADIUS := 8
const FILL_CORNER_RADIUS := 6
const FRAME_BORDER_WIDTH := 2

@export var damageBar : ProgressBar 
@export var damageEffectTimer : Timer

var health := 0 : set = setHealth
var _damageTween : Tween
var _visibilityTween : Tween

func _ready() -> void:
	_applyStyle()
	damageEffectTimer.wait_time = 0.25

static func create(maxHealth : int, currHealth : int = maxHealth) -> BossHealthBar:
	var scene := load("uid://4teqdk4j5ogj") as PackedScene
	var healthbar := scene.instantiate() as BossHealthBar
	
	healthbar.max_value = maxHealth
	healthbar.value = currHealth
	healthbar.health = currHealth
	healthbar.damageBar.max_value = maxHealth
	healthbar.damageBar.value = currHealth
	
	return healthbar

func prepareForIntro() -> void:
	_stopVisibilityTween()
	modulate.a = 0.0
	show()

func fadeIn(duration : float) -> Tween:
	_stopVisibilityTween()
	show()
	_visibilityTween = create_tween()\
		.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	_visibilityTween.tween_property(self, "modulate:a", 1.0, duration)
	return _visibilityTween

func setHealth(newHealth : int) -> void:
	var prevHealth = health
	health = min(newHealth, max_value)
	value = newHealth
	
	if health < prevHealth:
		_stopDamageTween()
		damageEffectTimer.start()
	else:
		_stopDamageTween()
		damageEffectTimer.stop()
		damageBar.value = health

## TODO: replace to set Health
func damage(newHealth : int) -> void:
	setHealth(newHealth)

func death(boss : Node) -> void:
	SignalManager.bossDefeated.emit()
	
	setHealth(0)
	await damageEffectTimer.timeout
	await get_tree().create_timer(DAMAGE_DRAIN_DURATION).timeout
	queue_free()

func _on_timer_timeout() -> void:
	_damageTween = create_tween()
	_damageTween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_damageTween.tween_property(damageBar, "value", health, DAMAGE_DRAIN_DURATION)

func _stopDamageTween() -> void:
	if _damageTween != null and _damageTween.is_valid():
		_damageTween.kill()
	_damageTween = null

func _stopVisibilityTween() -> void:
	if _visibilityTween != null and _visibilityTween.is_valid():
		_visibilityTween.kill()
	_visibilityTween = null

func _applyStyle() -> void:
	var healthFill := get_theme_stylebox("fill") as StyleBoxFlat
	_setCornerRadius(healthFill, FILL_CORNER_RADIUS)

	var frame := StyleBoxFlat.new()
	frame.bg_color = FRAME_COLOR
	frame.draw_center = false
	frame.border_color = FRAME_BORDER_COLOR
	frame.set_border_width_all(FRAME_BORDER_WIDTH)
	frame.set_content_margin_all(FRAME_BORDER_WIDTH)
	_setCornerRadius(frame, FRAME_CORNER_RADIUS)
	add_theme_stylebox_override("background", frame)

	var damageBackground := damageBar.get_theme_stylebox("background") as StyleBoxFlat
	damageBackground.bg_color = FRAME_COLOR
	_setCornerRadius(damageBackground, FRAME_CORNER_RADIUS)

	var damageFill := damageBar.get_theme_stylebox("fill") as StyleBoxFlat
	damageFill.bg_color = DAMAGE_COLOR
	_setCornerRadius(damageFill, FILL_CORNER_RADIUS)

func _setCornerRadius(styleBox : StyleBoxFlat, radius : int) -> void:
	styleBox.set_corner_radius_all(radius)
