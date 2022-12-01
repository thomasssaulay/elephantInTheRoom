extends KinematicBody2D

onready var _raycast = $RayCastCenter
onready var _raycastL = $RayCastLeft
onready var _raycastR = $RayCastRight
onready var _raycastL2 = $RayCastLeft2
onready var _raycastR2 = $RayCastRight2
onready var _collision = $CollisionShape2D
onready var _navigationAgent = $NavigationAgent2D
onready var _animation = $AnimationPlayer
onready var _animationTree = $AnimationTree
onready var _sprite = $Sprite
onready var _deathSprite = $DeathSprite

var speed : int = Globals.NPC_SPEED_MIN
var state : int = Globals.STATES.IDLE
var stateTimer := Timer.new()
var targetReached : bool = false
var isGameTarget : bool = false
var isAlert : bool = false
var info = null
var velocity : Vector2
var orientation : String = "e"
var currentRoom

func _ready():
	randomize()
	speed = int(rand_range(Globals.NPC_SPEED_MIN, Globals.NPC_SPEED_MAX))
	add_to_group("npc")
	stateTimer.one_shot = true
	stateTimer.wait_time = 2.0
	stateTimer.connect("timeout", self, "onStateTimer")
	stateTimer.autostart = true
	self.info = get_tree().get_root().get_node("Main").npcList[randi() % get_tree().get_root().get_node("Main").npcList.size()]
	_sprite.region_rect.position.y = 64 * self.info.index
	add_child(stateTimer)

func _physics_process(delta):
	match self.state:
		Globals.STATES.IDLE:
			detection(delta)
		Globals.STATES.DEAD:
			pass
		Globals.STATES.WANDER:
			moveToTarget()
			detection(delta)
		Globals.STATES.ALERT:
			moveToTarget()
			detection(delta)
			
func setGameTarget(npcIndex):
	self.isGameTarget = true
	self.info = Globals.NPC_LIST[npcIndex]
	_sprite.region_rect.position.y = 64 * self.info.index
	
func setState(newState):
	if self.state != Globals.STATES.DEAD:
		self.state = newState
		if newState == Globals.STATES.WANDER:
			_animationTree.get("parameters/playback").travel("walk")
			var chosenRoom = currentRoom
			if randf() < Globals.NPC_CHANCES_OF_LEAVING_ROOM:
				chosenRoom = get_tree().get_root().get_node("Main").rooms[ randi() % get_tree().get_root().get_node("Main").rooms.size() ]
				self.currentRoom = chosenRoom
			var locationVariation = Vector2(rand_range(0, Globals.NPC_LOCATION_VARIATION), rand_range(0, Globals.NPC_LOCATION_VARIATION)) * Globals.DIRECTIONS_VEC[ randi() % Globals.DIRECTIONS_VEC.size() ]
			var chosenLocation = chosenRoom.position + Vector2(chosenRoom.width / 2, chosenRoom.height / 2) + locationVariation
			setTarget(chosenLocation)
		if newState == Globals.STATES.IDLE:
			_animationTree.get("parameters/playback").travel("idle")
			# Timer before leaving
			stateTimer.start(rand_range(2,10))
		if newState == Globals.STATES.ALERT:
			if not self.isAlert:
				_animationTree.get("parameters/playback").travel("walk")
				self.stateTimer.stop()
				self.speed *= Globals.NPC_ALERT_SPEED_MULTIPLIER
				self.isAlert = true

func kill():
	_sprite.queue_free()
	_collision.queue_free()
	_navigationAgent.queue_free()
	_animation.queue_free()
	_animationTree.queue_free()
	_raycast.queue_free()
	_raycastL.queue_free()
	_raycastR.queue_free()
	_raycastL2.queue_free()
	_raycastR2.queue_free()
	_deathSprite.visible = true
	_deathSprite.play("default")
	self.setState(Globals.STATES.DEAD)
	if self.isGameTarget:
		get_tree().get_root().get_node("Main/HUDLayer/TargetLabelNode/TargetLabel").text = "Target is eliminated. You must escape QUICKLY."
		get_tree().get_root().get_node("Main").targetIsDead = true
		

func onStateTimer() -> void:
	if self.state != Globals.STATES.DEAD:
		if self.state == Globals.STATES.IDLE:
			self.setState(Globals.STATES.WANDER)
		elif self.state == Globals.STATES.WANDER:
			self.setState(Globals.STATES.IDLE)

# Entity moves towards a target 
func moveToTarget():
	if self.state != Globals.STATES.DEAD:
		var moveDirection = position.direction_to(_navigationAgent.get_next_location())	
		
		if _navigationAgent.is_navigation_finished():
			self.setState(Globals.STATES.IDLE)
		else:
			if !moveDirection == Vector2.ZERO:
				self.velocity = move_and_slide(moveDirection * speed)
				_animationTree.set("parameters/idle/blend_position", velocity)
				_animationTree.set("parameters/walk/blend_position", velocity)
				
func detection(delta):
	if self.state != Globals.STATES.DEAD:
		# Detection 
		
		for r in [ _raycast , _raycastL , _raycastL2 , _raycastR , _raycastR2 ]:
			r.cast_to = self.velocity.normalized() * Vector2(Globals.NPC_VISON, Globals.NPC_VISON)
			raycastDetection(r, delta)
			
#		_raycast.cast_to = self.velocity.normalized() * Vector2(Globals.NPC_VISON, Globals.NPC_VISON)
#		_raycastL.cast_to = self.velocity.normalized() * Vector2(Globals.NPC_VISON, Globals.NPC_VISON)
#		_raycastR.cast_to = self.velocity.normalized() * Vector2(Globals.NPC_VISON, Globals.NPC_VISON)
#		_raycastL2.cast_to = self.velocity.normalized() * Vector2(Globals.NPC_VISON, Globals.NPC_VISON)
#		_raycastR2.cast_to = self.velocity.normalized() * Vector2(Globals.NPC_VISON, Globals.NPC_VISON)
#		if _raycastL.is_colliding():
#			var coll = _raycastL.get_collider()
#			if coll.name == "Player":
#				get_tree().get_root().get_node("Main").playerDetectionLevel += delta * Globals.DETECTION_MULTIPLIER
#		if _raycastL2.is_colliding():
#			var coll = _raycastL2.get_collider()
#			if coll.name == "Player":
#				get_tree().get_root().get_node("Main").playerDetectionLevel += delta * Globals.DETECTION_MULTIPLIER
#		if _raycastR.is_colliding():
#			var coll = _raycastR.get_collider()
#			if coll.name == "Player":
#				get_tree().get_root().get_node("Main").playerDetectionLevel += delta * Globals.DETECTION_MULTIPLIER
#		if _raycastR2.is_colliding():
#			var coll = _raycastR2.get_collider()
#			if coll.name == "Player":
#				get_tree().get_root().get_node("Main").playerDetectionLevel += delta * Globals.DETECTION_MULTIPLIER

func raycastDetection(ray, delta):
	if ray.is_colliding():
		var coll = ray.get_collider()
		if coll.name == "Player":
			get_tree().get_root().get_node("Main").playerDetectionLevel += delta * Globals.DETECTION_MULTIPLIER
			
	


# Set a target position
func setTarget(t):
	if self.state != Globals.STATES.DEAD:
#		print(str(self.name) + " " + )
		_navigationAgent.set_target_location(t)
		
	
func escape():
	queue_free()
	if self.isGameTarget:
		get_tree().get_root().get_node("Main").failGame("escape")
