class_name ShaderAnimator
extends Node
@export var playerSprite : Sprite2D

var fadeCount := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !is_zero_approx(fadeCount):
		playerSprite.material.set_shader_parameter("flashAmount", fadeCount)
		fadeCount -= 0.02

# ngl, made with Gemini, thanks Gemini!
## Invlun Flash animation
func invulnFlash(blinkInterval : float, duration : float) -> void:
	# Strong white flash right when hit
	playerSprite.material.set_shader_parameter("flashAmount", 1.0)
	await get_tree().create_timer(0.08).timeout
	
	var elapsed := 0.0

	# Blink for the rest of the invincibility period
	while elapsed < duration:
		playerSprite.material.set_shader_parameter("flashAmount", 0.0)
		await get_tree().create_timer(blinkInterval).timeout
		elapsed += blinkInterval
		
		playerSprite.material.set_shader_parameter("flashAmount", 1.0)
		await get_tree().create_timer(blinkInterval).timeout
		elapsed += blinkInterval

	# Reset sprite
	playerSprite.material.set_shader_parameter("flashAmount", 0.0)
	pass

func respawnFadeIn() -> void:
	playerSprite.material.set_shader_parameter("flashAmount", 1.0)
	fadeCount = 1.0	
