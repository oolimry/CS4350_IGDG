extends BossState
class_name BossStateMeleeAttack

var randomizer : RandomNumberGenerator
var kickRadius : float = 800

func setup(getB : Callable, getP : Callable, dependencies : Dictionary) -> void:
	super.setup(getB, getP, dependencies)
	randomizer = RandomNumberGenerator.new()
	randomizer.randomize()

func _start() -> void:
	var player : Node2D = getPlayer.call()
	var boss : Node2D = getBoss.call()
	var ap = boss.get_node("AnimationPlayer") as AnimationPlayer
	
	var feetReferencePoint : Vector2 = \
		boss.get_node("CharacterContainer/FootReference").global_position
	
	if getPlayer.call().global_position.x <= getBoss.call().global_position.x:
		var randValue = randomizer.randi()
		
		if randomizer.randi() % 2 == 0:
			if feetReferencePoint.y < player.global_position.y:
				ap.play("foot_r_stomp")
			else:
				ap.play("arm_r_hit")
		else:
			ap.play("arm_r_swing")
	else:
		if randomizer.randi() % 2 == 0:
			if feetReferencePoint.y < player.global_position.y:
				ap.play("foot_l_stomp")
			else:
				ap.play("arm_l_hit")
		else:
			ap.play("arm_l_swing")
			
	await ap.animation_finished
	_end()

func _end() -> void:
	transitionTo.emit("Idle")
	pass
