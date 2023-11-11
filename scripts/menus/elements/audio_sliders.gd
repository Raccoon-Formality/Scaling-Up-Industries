extends Control

func _ready():
	updateSliders()

func updateSliders():
	$MainSlider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$MusicSlider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("music")))
	$SFXSlider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sfx")))
	$Main.text = "Main"
	$Music.text = "Music"
	$SFX.text = "SFX"

func _on_MainSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value))
	$Main.text = str(value * 100) + "%"


func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), linear2db(value))
	$Music.text = str(value * 100) + "%"


func _on_SFXSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"), linear2db(value))
	$SFX.text = str(value * 100) + "%"


func _on_MainSlider_drag_ended(_value_changed):
	$Main.text = "Main"
	Global.saveSettings()


func _on_MusicSlider_drag_ended(_value_changed):
	$Music.text = "Music"
	Global.saveSettings()


func _on_SFXSlider_drag_ended(_value_changed):
	$SFX.text = "SFX"
	Global.saveSettings()
