extends AudioStreamPlayer

var index = AudioServer.get_bus_index("MusicBus")
var lowPass = AudioServer.get_bus_effect(index, 0)
var activeLowPass = true

func _process(delta):
	if activeLowPass:
		lowPass.cutoff_hz = lerp(lowPass.cutoff_hz, 250, 0.01)
	else:
		lowPass.cutoff_hz = lerp(lowPass.cutoff_hz, 2500, 0.01)
