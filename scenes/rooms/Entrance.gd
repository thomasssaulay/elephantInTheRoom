extends Node2D

var entrHorSprite = preload("res://assets/world/entrance_hor.png")
var entrSouthSprite = preload("res://assets/world/entrance_s.png")
var entrVerSprite = preload("res://assets/world/entrance.png")
var longNav = preload("res://assets/world/longnavpoly.tres")
var shortNav = preload("res://assets/world/shortnavpoly.tres")

onready var _sprite = $Sprite
onready var _area = $Area2D
onready var _collLeft = $CollisionLeft
onready var _collRight = $CollisionRight
onready var _collBottom = $CollisionBottom
onready var _audioOutArea = $AudioOutArea
onready var _navPoly = $NavigationPolygonInstance

func setOrientation(wallConnected):
	match wallConnected:
		"WallW":
			_sprite.texture = entrHorSprite
			_area.position = Vector2(100,310)
			_collRight.get_node("CollisionShape2D").shape.extents = Vector2(20,640)
			_collLeft.position = Vector2(640,210)
			_collLeft.rotation_degrees = 90
			_collRight.position = Vector2(640,390)
			_collRight.rotation_degrees = 90
			_collBottom.position = Vector2(170,310)
			_collBottom.rotation_degrees = 90
			_navPoly.rotation_degrees = 0
			_navPoly.position.x = 0
			_navPoly.navpoly = longNav
		"WallE":
			_sprite.texture = entrHorSprite
			_sprite.flip_h = true
			_area.position = Vector2(1180,310)
			_collRight.get_node("CollisionShape2D").shape.extents = Vector2(20,640)
			_collLeft.position = Vector2(640,210)
			_collLeft.rotation_degrees = 90
			_collRight.position = Vector2(640,390)
			_collRight.rotation_degrees = 90
			_collBottom.position = Vector2(1130,310)
			_collBottom.rotation_degrees = 90
			_navPoly.rotation_degrees = 0
			_navPoly.position.x = 0
			_navPoly.navpoly = longNav
		"WallN":
			_sprite.texture = entrSouthSprite
			_area.position = Vector2(640,100)
			_collRight.get_node("CollisionShape2D").shape.extents = Vector2(20,320)
			_collLeft.position = Vector2(540,450)
			_collLeft.rotation_degrees = 0
			_collRight.position = Vector2(730,450)
			_collRight.rotation_degrees = 0
			_collBottom.position = Vector2(640,150)
			_collBottom.rotation_degrees = 0 
			_navPoly.rotation_degrees = 90
			_navPoly.position.x = 930
			_navPoly.navpoly = shortNav
		"WallS":
			_sprite.texture = entrVerSprite
			_area.position = Vector2(640,630)
			_collRight.get_node("CollisionShape2D").shape.extents = Vector2(20,320)
			_collLeft.position = Vector2(540,320)
			_collLeft.rotation_degrees = 0
			_collRight.position = Vector2(730,320)
			_collRight.rotation_degrees = 0
			_collBottom.position = Vector2(640,600)
			_collBottom.rotation_degrees = 0 
			_navPoly.rotation_degrees = 90
			_navPoly.position.x = 930
			_navPoly.navpoly = shortNav
			
			

func _on_Area2D_body_entered(body):
	if body.is_in_group("npc"):
		body.escape()
	if body.name == "Player" and get_tree().get_root().get_node("Main").targetIsDead:
		get_tree().get_root().get_node("Main").winGame()
		


func _on_AudioOutArea_body_entered(body):
	if body.name == "Player":
		get_tree().get_root().get_node("Main/MusicPlayer").activeLowPass = true

func _on_AudioOutArea_body_exited(body):
	if body.name == "Player":
		get_tree().get_root().get_node("Main/MusicPlayer").activeLowPass = false
