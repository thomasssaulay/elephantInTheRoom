extends Node2D

onready var _timer = get_node("Timer")
onready var _pb = get_node("ProgressBar")

var levelTime = 90.0
var suspected = false
	
func startTimer():
	self.levelTime = clamp(Globals.MAX_GAME_TIMER - Globals.currentLevel * 5, Globals.MIN_GAME_TIMER, Globals.MAX_GAME_TIMER)
	_timer.start(self.levelTime)
	
func stopTimer():
	_timer.stop()

func _process(delta):
#	_pb.value = abs((_timer.time_left - self.levelTime) / self.levelTime * 100)
	if not suspected:
		_pb.value = get_tree().get_root().get_node("Main").playerDetectionLevel * 10
		
func _on_Timer_timeout():
	if get_tree().get_root().get_node("Main").targetIsDead:
		get_tree().get_root().get_node("Main").failGame("cops")
	else:
		get_tree().get_root().get_node("Main").failGame("timeout")


func _on_ProgressBar_value_changed(value):
	if value >= 100:
		suspected = true
		get_tree().get_root().get_node("Main").failGame("suspected")
		
