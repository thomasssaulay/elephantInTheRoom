extends Node2D

var noteSprite = preload("res://assets/hud/note.png")
var failSprite = preload("res://assets/hud/fail.png")
var winSprite = preload("res://assets/hud/win.png")

onready var _sprite = $Sprite
onready var _shadowSprite = $ShadowSprite
onready var _label = $RichTextLabel
onready var _timer = $Timer
onready var _bottomLabel = $BottomLabel

enum STATES { START , WIN , FAIL }
var state = STATES.START

func _process(delta):
	if not _timer.paused and self.state == STATES.START:
		_bottomLabel.text = "This note will self-destruct in " + str(int(_timer.time_left) + 1)

func setNoteScreen(npcInfo):
	_sprite.texture = noteSprite
	_shadowSprite.frame = int(npcInfo.index / 3)
	_shadowSprite.visible = true
	get_tree().get_root().get_node("Main").gameFrozen = true
	_label.text = "The target is a " + str(Globals.NPC_LIST[ npcInfo.index ].name)
	_label.visible = true
	self.state = STATES.START
	_timer.start(5.0)
	self.visible = true

func setFailScreen(reason = "timeout"):
	_sprite.texture = failSprite
	_label.visible = false
	_shadowSprite.visible = false
	get_tree().get_root().get_node("Main").gameFrozen = true
#	get_tree().get_root().get_node("Main/HUDLayer/GameTimer").stopTimer()
	self.state = STATES.FAIL
	if reason == "timeout":
		_bottomLabel.text = "Too late ! Target has left the manor."
	if reason == "escape":
		_bottomLabel.text = "Target has escaped."
	if reason == "cops":
		_bottomLabel.text = "You didnt left the manor on time."
	if reason == "suspected":
		_bottomLabel.text = "You were acting too suspicious."
	_timer.start(5.0)
	self.visible = true
	
func setWinScreen():
	_sprite.texture = winSprite
	_label.visible = false
	get_tree().get_root().get_node("Main").gameFrozen = true
#	get_tree().get_root().get_node("Main/HUDLayer/GameTimer").stopTimer()
	_shadowSprite.visible = false
	self.state = STATES.WIN
	_bottomLabel.text = "Well done. Target has been eliminated."
	_timer.start(5.0)
	self.visible = true
		
func _on_Timer_timeout():
	self.visible = false
	get_tree().get_root().get_node("Main").gameFrozen = false
#	get_tree().get_root().get_node("Main/HUDLayer/GameTimer").startTimer()
	if self.state == STATES.FAIL:
		get_tree().reload_current_scene()
	if self.state == STATES.WIN:
		get_tree().reload_current_scene()
