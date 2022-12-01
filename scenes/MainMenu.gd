extends Control

onready var _popup = $Popup
onready var _back = $TextureRect

var direct : bool = true
var counter : float = 0
var red : float
var blue : float

func _physics_process(delta):
	if counter >= 0.2:
		direct = false
	if counter <= -0.2:
		direct = true
#
	if direct:
		counter += delta * 0.5
	else:
		counter -= delta * 0.5
	_back.material.set_shader_param("red_displacement", counter)
	_back.material.set_shader_param("blue_displacement", -counter)

func _on_MenuButton_pressed():
	get_tree().change_scene("res://scenes/Main.tscn")

func _on_CreditButton_pressed():
	_popup.popup()

func _on_Popup_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			_popup.hide()
