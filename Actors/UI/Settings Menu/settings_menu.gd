extends Control

@onready
var mainMenuButton = $MarginContainer/VBoxContainer/HBoxContainer2/MainMenuButton

@onready
var buttonMarginContainer = $MarginContainer/VBoxContainer/HBoxContainer2/MarginContainer

func _ready():
	SignalManager.openSettings.connect(openSettingsMenu)

func _on_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))


func _on_sound_effects_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Audio"), linear_to_db(value))

func openSettingsMenu():
	if self.visible == true:
		self.visible = false
	else:
		if self.get_parent().get_parent().mainMenu.visible == true:
			mainMenuButton.visible = false
			buttonMarginContainer.visible = false
		else:
			mainMenuButton.visible = true
			buttonMarginContainer.visible = true
		self.visible = true
	

func _on_return_button_pressed() -> void:
	self.visible = false
	
func _on_main_menu_button_pressed() -> void:
	self.visible = false
	SignalManager.showCredits.emit()
