extends Node

const ROOM = preload("res://scenes/rooms/Room.tscn")
const ENTRANCE = preload("res://scenes/rooms/Entrance.tscn")

onready var _player = $YSort/Player
onready var _targetLabel = $HUDLayer/TargetLabelNode/TargetLabel
onready var _levelLabel = $HUDLayer/LevelLabelNode/LevelLabel
onready var _menu = $HUDLayer/Menu
var nRooms : int = 5
var minNpcPerRoom : int = 1
var maxNpcPerRoom : int = 8
var rooms : Array = []
var firstRoom = null
var entrance = null
var targetInfo = null
var targetNPC = null
var targetIsDead = false
var npcList : Array = []
var targetIndex : int
var mapRangeX := Vector2.ZERO
var mapRangeY := Vector2.ZERO
var gameFrozen = true
var playerDetectionLevel = 0

func _ready():
	randomize()
	
	self.nRooms = 12 + Globals.currentLevel
	self.minNpcPerRoom = 1
	self.maxNpcPerRoom = 2 + Globals.currentLevel
	
	self.npcList = [] + Globals.NPC_LIST
	self.targetIndex = randi() % Globals.NPC_LIST.size()
	self.targetInfo = Globals.NPC_LIST[ self.targetIndex ]
	
	_menu.setNoteScreen(self.targetInfo)
	if Globals.currentLevel == 1:
		_targetLabel.text = "The target is a " + str(Globals.NPC_LIST[ self.targetIndex ].name)
	else:
		_targetLabel.text = ""
	_levelLabel.text = "LEVEL " + str(Globals.currentLevel)
	self.npcList.remove(self.targetIndex)
	
	generateLevel()
	
	self.targetNPC = self.rooms[3 + randi() % (self.rooms.size() - 3)].spawnGameTarget(self.targetIndex)
	self.gameFrozen = true
	
func _process(_delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func generateLevel():
	# RNG start
	randomize()
	# We add the first room in a list of room coordinates
	var usedCoords = [ Vector2(0,0) ]
	# We add the starting room
	rooms.push_back( ROOM.instance().init("ROOM0",Vector2(0,0)) )
	self.add_child(rooms[0])
	# Last coords walked in by the walker
	var lastCoords := Vector2(0,0)
	# One room is already created
	var roomsLeft = nRooms - 1
	var roomIndex = 0
	# Keep last room for door creation
	var lastRoom = rooms[-1]
	
	while(roomsLeft > 0):
		# Choose random direction for the walker to go to
		var indexDir = randi() % Globals.DIRECTIONS.size()
		var dir = Globals.DIRECTIONS[ indexDir ]
		# Those are the new current coordinates
		var curCoords := Vector2(lastCoords[0] + dir[0], lastCoords[1] + dir[1])
		# If they are not already in the rooms coordinates list
		if not curCoords in usedCoords:
			# We add them to the list
			usedCoords.push_back(curCoords)
			# We add the new room
			# And we connect the wall between the rooms to create a door inside
			rooms.push_back(ROOM.instance().init("ROOM" + str(nRooms - roomsLeft),
				Vector2(curCoords.x, curCoords.y)))
			# On this room, the door is at the last direction taken
			if not Globals.OPPOSITE_WALL_LIST[indexDir] in rooms[-1].connectedWalls:
				rooms[-1].connectedWalls.push_back(Globals.OPPOSITE_WALL_LIST[indexDir])
			# On the room before, the door is in the direction we just took
			if not Globals.WALL_LIST[indexDir] in lastRoom.connectedWalls:
				lastRoom.connectedWalls.push_back(Globals.WALL_LIST[indexDir])
			self.add_child(rooms[-1])
			# One room less to create
			roomsLeft -= 1
		else:
			# If the room exited, still connect walls between those rooms
			if not Globals.WALL_LIST[indexDir] in lastRoom.connectedWalls:
				lastRoom.connectedWalls.push_back(Globals.WALL_LIST[indexDir])
			
		# If the room in those coords existed already or not, change the last coordinates of the walker
		lastCoords = curCoords
		for room in self.rooms:
			# Keep track of the last room (for doors connection)
			if lastCoords == room.coord:
				lastRoom = room

	# Entrance placement
	var firstRoomCoord = Vector2.ZERO
	var entranceDirIndex : int = -1
	for c in usedCoords:
		for i in range(Globals.DIRECTIONS_VEC.size()):
			if not (c + Globals.DIRECTIONS_VEC[i]) in usedCoords and entranceDirIndex == -1:
				entranceDirIndex = i
				firstRoomCoord = c
				break

	usedCoords.sort()
	# Keep the map range horizontally
	mapRangeX = Vector2(usedCoords[0].x, usedCoords[-1].x)
	usedCoords.sort_custom(self, "sortByY")
	# Keep the map range vertically
	mapRangeY = Vector2(usedCoords[0].x, usedCoords[-1].x)
	
	for room in self.rooms:
		var foundRoomOnTop = false
		for r in self.rooms:
			if Vector2(room.coord.x, room.coord.y - 1) == r.coord:
				foundRoomOnTop = true
				break
		if not foundRoomOnTop:
			room.createTopBorder()
			
		# Place the entrance door
		if room.coord == firstRoomCoord:
			self.firstRoom = room
			room.connectedWalls.push_back(Globals.WALL_LIST[entranceDirIndex])
			self.entrance = ENTRANCE.instance()
			self.entrance.position = self.firstRoom.position + Globals.DIRECTIONS_VEC[entranceDirIndex] * Vector2(self.firstRoom.width, self.firstRoom.height)
			add_child(self.entrance)
			self.entrance.setOrientation(Globals.WALL_LIST[entranceDirIndex])
			if Globals.WALL_LIST[entranceDirIndex] == "WallN":
				# Top border fix
				room.removeTile(Vector2(4,-1))
				room.removeTile(Vector2(5,-1))
			
		
		# Place doors in all the created rooms
		room.createDoors()
		
		# Create large rooms
		if room.roomType == "simple":
			if "WallE" in room.connectedWalls and randf() < Globals.LARGE_ROOM_CHANCE:
				# Find adjacent room
				var ajdRoom = null
				for r in self.rooms:
					if r.coord == Vector2(room.coord.x + 1, room.coord.y):
						ajdRoom = r
				if ajdRoom != null and ajdRoom.roomType == "simple":
					ajdRoom.wallFrame = room.wallFrame
					ajdRoom.floorFrame = room.floorFrame
					room.roomType = "largeE"
					ajdRoom.roomType = "largeW"
					ajdRoom.updateTilesFrame()
					room.removeWall("WallE")
					ajdRoom.removeWall("WallW")
			
			if "WallS" in room.connectedWalls and randf() < Globals.LARGE_ROOM_CHANCE:
				# Find adjacent room
				var ajdRoom = null
				for r in self.rooms:
					if r.coord == Vector2(room.coord.x, room.coord.y + 1):
						ajdRoom = r
				if ajdRoom != null and ajdRoom.roomType == "simple":
					ajdRoom.wallFrame = room.wallFrame
					ajdRoom.floorFrame = room.floorFrame
					room.roomType = "largeS"
					ajdRoom.roomType = "largeN"
					ajdRoom.updateTilesFrame()
					room.removeWall("WallS")
					ajdRoom.removeWall("WallN")
					
		# Set disco route
		if (randf() < Globals.DISCO_ROOM_CHANCE):
			room.setDiscoRoom()
		
		room.addFurnitures()
		# Then spawn NPCs into rooms
		room.spawnNPC(int(rand_range(minNpcPerRoom,maxNpcPerRoom)))
	
	for room in self.rooms:
		# TEMPORARY FIX !! NOT OPTIMIZED
		room.createDoors()
		
		
	# Player placement
	_player.position = self.entrance.position + Vector2(self.firstRoom.width/2, self.firstRoom.height/2 - 64)
		
func sortByY(a, b):
	return a.y < b.y
	
func removeWallBetween(wallOrientation, room1, room2):
	print("Removing " + str(wallOrientation) + " on room " + str(room1.roomName))
	match wallOrientation:
		"WallE":
			# Remove the walls between the rooms, from 15, 2 to 15, 6
			for y in range(1,7):
				room1.removeTile(Vector2(11,y))
				room2.removeTile(Vector2(0,y))
				room1.setFloorTile(Vector2(11,y))
				room2.setFloorTile(Vector2(0,y))
			# Adjust walls
			# TODO :::::::::::::::::::
		"WallS":
			for x in range(1,11):
				room1.removeTile(Vector2(x,7))
				room2.removeTile(Vector2(x,0))
				room1.setFloorTile(Vector2(x,7))
				room2.setFloorTile(Vector2(x,0))
			# Adjust walls
			room1.setWestWallTile(Vector2(0,6))
			room1.setEastWallTile(Vector2(11,6))
			room1.setWestWallTile(Vector2(0,7))
			room1.setEastWallTile(Vector2(11,7))
	# The two rooms become "large" rooms
	room1.roomType = "large"
	room2.roomType = "large"

func alertAllNpc():
	get_tree().call_group("npc", "setState", Globals.STATES.ALERT) 
	get_tree().call_group("npc", "setTarget", self.entrance._area.global_position)
	
func pauseGame():
	if get_tree().paused == true:
		get_tree().paused == false
	else:
		get_tree().paused == true
	
func winGame():
	Globals.currentLevel += 1
	_menu.setWinScreen()
	
func failGame(reason):
	_menu.setFailScreen(reason)

func _on_Button_pressed():
	pauseGame()
