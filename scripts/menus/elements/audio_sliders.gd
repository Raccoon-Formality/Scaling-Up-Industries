extends Control

func _ready():
	$MainSlider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$MusicSlider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("music")))
	$SFXSlider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sfx")))

func updateSliders():
	$MainSlider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$MusicSlider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("music")))
	$SFXSlider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sfx")))

func _on_MainSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value))


func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), linear2db(value))


func _on_SFXSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"), linear2db(value))
