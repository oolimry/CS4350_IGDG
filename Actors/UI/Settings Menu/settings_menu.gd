extends Control

func _ready():
	SignalManager.openSettings.connect(openSettingsMenu)

func _on_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))


func _on_sound_effects_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Audio"), linear_to_db(value))

func openSettingsMenu():
	self.visible = true

func _on_button_pressed() -> void:
	self.visible = false
