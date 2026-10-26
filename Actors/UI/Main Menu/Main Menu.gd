class_name MainMenu
extends Control

@onready var startButton : Button = $MarginContainer/VBoxContainer/ButtonContainer/Start

func _on_quit_pressed():
	get_tree().quit()

func _on_settings_pressed() -> void:
	SignalManager.openSettings.emit()
