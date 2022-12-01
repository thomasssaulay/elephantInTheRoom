extends KinematicBody2D

onready var _raycast = $RayCast2D
onready var _camera = $Camera2D
onready var _animationTree = $AnimationTree
onready var _particle = $Particles2D
onready var _noiseArea = $NoiseDetectionArea
onready var _audioPlayer = $AudioStreamPlayer2D
onready var _eye = $EyeSprite

const NPC = preload("res://entities/NPC.tscn")
const Bullet = preload("res://entities/Bullet.tscn")

const friction = 0.1
const acceleration = 0.1
var velocity := Vector2.ZERO
var isShooting : bool = false
var shootingTimer := Timer.new()
var ammoRemaining : int = 3

func _ready():
	# Shooting timer setup
	shootingTimer.one_shot = true
	shootingTimer.autostart = true
	shootingTimer.wait_time = 0.8
	shootingTimer.connect("timeout", self, "onShootTimer")
	add_child(shootingTimer)
	# Wait for entities init
	yield(get_tree(), "idle_frame")

func _physics_process(_delta):
	# CAMERA EFFECT
	var mouse_offset = (get_viewport().get_mouse_position() - get_viewport().size / 2)
	_camera.position = lerp(Vector2(), mouse_offset.normalized() * 500, mouse_offset.length() / 1000)
	
	if not self.isShooting and not get_parent().get_parent().gameFrozen:
		# MOVE CONTROL
		var direction = getInput()
		if direction.length() > 0:
			velocity = lerp(velocity, direction.normalized() * Globals.PLAYER_SPEED, acceleration)
		else:
			velocity = lerp(velocity, Vector2.ZERO, friction)
		velocity = move_and_slide(velocity)
		
		if abs(velocity.x) < 25 and abs(velocity.y) < 25:
			velocity.x = 0
			velocity.y = 0

		if velocity != Vector2.ZERO:
			_animationTree.get("parameters/playback").travel("walk")
			_animationTree.set("parameters/walk/blend_position", velocity)
		else:
			_animationTree.get("parameters/playback").travel("idle")
	#		_animationTree.set("parameters/idle/blend_position", velocity)
		
		var sight = get_global_mouse_position() - global_position
		_raycast.rotation = atan2(sight.y, sight.x)
	#	_animationTree.set("parameters/walk/blend_position", sight.normalized())
		_animationTree.set("parameters/idle/blend_position", sight.normalized())
		
		# SHOOT CONTROL
		if Input.is_action_just_pressed("shoot") and self.ammoRemaining >= 1:
			shoot()
			
		# PAUSE
		if Input.is_action_just_pressed("ui_cancel"):
			get_tree().get_root().get_node("Main").pauseGame()
			
		# DEBUG !
		if Input.is_action_just_pressed("right_button"):
#			var npc = NPC.instance()
#			npc.position = get_global_mouse_position()
			self.global_position = get_global_mouse_position()
#			for room in get_tree().get_root().get_node("Main").rooms:
#				if npc.position.x >= room.position.x and npc.position.x < room.position.x + room.width and npc.position.y >= room.position.y and npc.position.y < room.position.y + room.height:
#					npc.currentRoom = room
#			get_tree().get_root().get_node("Main/YSort").add_child(npc)
#		if Input.is_action_just_pressed("ui_select"):
#			get_tree().call_group("npc", "setState", Globals.STATES.WANDER) 
#			get_tree().call_group("npc", "setTarget", self.position) 
		
	# CAMERA FOR DEBUG
#	if Input.is_action_pressed("ui_up"):
#		_camera.zoom.x += 0.1
#		_camera.zoom.y += 0.1
#	if Input.is_action_pressed("ui_down"):
#		_camera.zoom.x -= 0.1
#		_camera.zoom.y -= 0.1
#	if Input.is_action_pressed("ui_left"):
#		_camera.position.x += 10
#	if Input.is_action_pressed("ui_right"):
#		_camera.position.x -= 10
		
func getInput():
	var input = Vector2()
	if Input.is_action_pressed('move_right'):
		input.x += 1
	if Input.is_action_pressed('move_left'):
		input.x -= 1
	if Input.is_action_pressed('move_down'):
		input.y += 1
	if Input.is_action_pressed("move_up"):
		input.y -= 1
	return input
	
		
func shoot():
	shootingTimer.start()
	self.isShooting = true
	var bullet = Bullet.instance()
	bullet.global_position = self.position
	bullet.rotation = _raycast.rotation
	get_tree().get_root().get_node("Main").add_child(bullet)
	_camera.shake(0.2,30,20)
#	get_tree().get_root().get_node("Main").alertAllNpc()
	var suspicionToAdd = 0
	for body in _noiseArea.get_overlapping_bodies():
		suspicionToAdd += 0.1 * Globals.DETECTION_MULTIPLIER
		print(suspicionToAdd)
		if body.is_in_group("npc"):
			body.setState(Globals.STATES.ALERT)
			body.setTarget(get_tree().get_root().get_node("Main").entrance._area.global_position)
	get_tree().get_root().get_node("Main").playerDetectionLevel += suspicionToAdd
		
	_particle.rotation = _raycast.rotation
	var particleDirection = Vector2(cos(_particle.rotation), sin(_particle.rotation))
	_particle.position = particleDirection * Vector2(32,32)
	_particle.emitting = true
	_animationTree.get("parameters/playback").travel("shoot")
	_animationTree.set("parameters/shoot/blend_position", particleDirection)
	_audioPlayer.play(0.15)
	self.ammoRemaining -= 1
	get_tree().get_root().get_node("Main/HUDLayer/AmmoLabelNode/AmmoLabel").text = str(self.ammoRemaining) + "/3"
#	print(particleDirection) # BORDEL DE MERDE
	
func onShootTimer():
	self.isShooting = false
