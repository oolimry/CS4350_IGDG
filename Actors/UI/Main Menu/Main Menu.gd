class_name MainMenu
extends Control

@onready var startButton : Button = $MarginContainer/VBoxContainer/ButtonContainer/Start


func _on_quit_pressed():
	get_tree().quit()


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Actors/UI/Settings Menu/SettingsMenu.tscn")
