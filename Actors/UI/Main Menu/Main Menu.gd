class_name MainMenu
extends Control

@onready var startButton : Button = $MarginContainer/VBoxContainer/ButtonContainer/Start


func _on_quit_pressed():
	get_tree().quit()
