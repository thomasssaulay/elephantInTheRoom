extends Node2D

var roomName : String = "ROOM"
var roomType : String = "simple"
var width : int = Globals.ROOM_WIDTH
var height : int = Globals.ROOM_HEIGHT
const endRoomCoord = Vector2(9,5) #11,7
var coord := Vector2.ZERO
var connectedWalls : Array = []
var isDiscoRoom : bool = false
var lightColor : Color
var prevLightColor : Color = Globals.DISCO_ROOM_COLORS[0]
var lightColorIndex : int = 0
var lightCount : float = 0.0
const TARGET_TIME = 1

var NPC = preload("res://entities/NPC.tscn")
var Door = preload("res://entities/Door.tscn")

var floorFrame : int = 0
var wallFrame : int = 0

onready var _label = $LabelNode/Label
onready var _borderTilemap = $BorderTileMap
onready var _wallTilemap = $WallTileMap
onready var _floorTilemap = $FloorTileMap
#onready var _furnitureTilemap = $FurnitureTileMap
onready var _light = $Light2D

# Room type can be : simple or large
func init(name, coordinates): 
	self.roomName = name
	self.coord = coordinates
	self.position = Vector2(self.coord.x * self.width, self.coord.y * self.height)
	return self
	
func _ready():
	floorFrame = randi() % 20
	wallFrame = randi() % 3
	updateTilesFrame()
	
func _process(delta):
	if isDiscoRoom:
		lightCount += delta
		if lightCount > TARGET_TIME:
			lightColorIndex += 1
			lightCount = 0
		if lightColorIndex > (Globals.DISCO_ROOM_COLORS.size() - 1): 
			lightColorIndex = 0
		lightColor = Color(Globals.DISCO_ROOM_COLORS[lightColorIndex])
#		_light.color = lightColor
		prevLightColor = _light.color
		_light.color = Color(prevLightColor.linear_interpolate(lightColor, lightCount))
		
	
func createDoors():
	# Update _label for debug
	self._label.text = str(self.roomName) + " | " + str(self.coord) + " | " + str(self.connectedWalls) + " || " + str(self.roomType)
	
	for wall in self.connectedWalls:
		for doorCoord in Globals.WALL_DOOR_COORD[wall]:
			removeTile(doorCoord)
			setFloorTile(doorCoord)
#			var door = Door.instance()
#			door.position = self.position + doorCoord * Vector2(128,128)
#			self.add_child(door)
			if wall == "WallE" and self.roomType != "largeE":
				removeTile(Vector2(doorCoord.x, doorCoord.y - 1))
				setWallTile(Vector2(doorCoord.x, doorCoord.y - 1))
				setEastCornerTile(Vector2(doorCoord.x, doorCoord.y + 1))
			if wall == "WallW" and self.roomType != "largeW":
				removeTile(Vector2(doorCoord.x, doorCoord.y - 1))
				setWallTile(Vector2(doorCoord.x, doorCoord.y - 1))
				setWestCornerTile(Vector2(doorCoord.x, doorCoord.y + 1))
		if wall == "WallS" and self.roomType != "largeS":
			setWestCornerTile(Vector2(Globals.WALL_DOOR_COORD[wall][0].x - 1, Globals.WALL_DOOR_COORD[wall][0].y))
			setEastCornerTile(Vector2(Globals.WALL_DOOR_COORD[wall][1].x + 1, Globals.WALL_DOOR_COORD[wall][0].y))

func createTopBorder():
	for x in range(1,endRoomCoord.x):
		setNorthWallTile(Vector2(x,-1))
	setWestInsideCornerTile(Vector2(0,-1))
	setEastInsideCornerTile(Vector2(endRoomCoord.x,-1))
	setWindowedWallTile(Vector2(1, 0))
	setWindowedWallTile(Vector2(5, 0))

func spawnNPC(amount):
	for i in range(0,amount):
		var npc = NPC.instance()
		npc.position = self.position + Vector2(rand_range(128,self.width - 128), rand_range(128,self.height - 128))
		npc.currentRoom = self
		get_tree().get_root().get_node("Main/YSort").add_child(npc)
		
func spawnGameTarget(npcIndex):
	var npc = NPC.instance()
	npc.position = self.position + Vector2(rand_range(128,self.width - 128), rand_range(128,self.height - 128))
	npc.currentRoom = self
	get_tree().get_root().get_node("Main/YSort").add_child(npc)
	npc.setGameTarget(npcIndex)
	return npc
	
func setDiscoRoom():
	self.isDiscoRoom = true

func updateTilesFrame():
	# Floor tiles 
	for x in range(1,endRoomCoord.x): 
		for y in range(1,endRoomCoord.y): 
			setFloorTile(Vector2(x, y))
	# Wall tiles 
	for x in range(1,endRoomCoord.x):
		setWallTile(Vector2(x, 0))
	setSpecialWallTile(Vector2(2, 0))
#	setSpecialWallTile(Vector2(4, 0))
	setSpecialWallTile(Vector2(6, 0))
#	setSpecialWallTile(Vector2(8, 0))
	
func addFurnitures():
	randomize()
	var chosenFurnitureIndex = randi() % 7 + 1
	for i in range(1,8):
		if i != chosenFurnitureIndex:
			get_node("FurnitureTileMap" + str(i)).queue_free()
		else:
			get_node("FurnitureTileMap" + str(i)).visible = true
		
	
func removeWall(orientation):
	match orientation:
		"WallN":
			for x in range(1,endRoomCoord.x):
				removeTile(Vector2(x,0))
				setFloorTile(Vector2(x,0))
				
		"WallS":
			for x in range(1,endRoomCoord.x):
				removeTile(Vector2(x,endRoomCoord.y))
				setFloorTile(Vector2(x,endRoomCoord.y))
			setWestWallTile(Vector2(0,endRoomCoord.y))
			setEastWallTile(Vector2(endRoomCoord.x,endRoomCoord.y))
		"WallW":
			for y in range(1,endRoomCoord.y):
				removeTile(Vector2(0,y))
				setFloorTile(Vector2(0,y))
			removeTile(Vector2(0,0))
			setWallTile(Vector2(0,0))
			setSouthWallTile(Vector2(0,endRoomCoord.y))
		"WallE":
			for y in range(1,endRoomCoord.y):
				removeTile(Vector2(endRoomCoord.x,y))
				setFloorTile(Vector2(endRoomCoord.x,y))
			removeTile(Vector2(endRoomCoord.x,0))
			setWallTile(Vector2(endRoomCoord.x,0))
			setSouthWallTile(Vector2(endRoomCoord.x,endRoomCoord.y))
	
func removeTile(tileCoord):
	_wallTilemap.set_cellv(tileCoord, -1)
	_borderTilemap.set_cellv(tileCoord, -1)
	_floorTilemap.set_cellv(tileCoord, -1)
#	_furnitureTilemap.set_cellv(tileCoord, -1)
	
func setFloorTile(tileCoord):
	_floorTilemap.set_cellv(tileCoord, floorFrame)
	
func setWallTile(tileCoord):
	_wallTilemap.set_cellv(tileCoord, wallFrame * 7)
	
func setWindowedWallTile(tileCoord):
	_wallTilemap.set_cellv(tileCoord, wallFrame * 7 + 1 + randi() % 2)
	
func setSpecialWallTile(tileCoord):
	_wallTilemap.set_cellv(tileCoord, wallFrame * 7 + 3 + randi() % 4)
	
func setEastWallTile(tileCoord):
	_borderTilemap.set_cellv(tileCoord, 7)

func setNorthWallTile(tileCoord):
	_borderTilemap.set_cellv(tileCoord, 1)
	
func setWestWallTile(tileCoord):
	_borderTilemap.set_cellv(tileCoord, 6)
	
func setSouthWallTile(tileCoord):
	_borderTilemap.set_cellv(tileCoord, 4)
	
func setWestCornerTile(tileCoord):
	_borderTilemap.set_cellv(tileCoord, 10)
	
func setEastCornerTile(tileCoord):
	_borderTilemap.set_cellv(tileCoord, 11)
	
func setEastInsideCornerTile(tileCoord):
	_borderTilemap.set_cellv(tileCoord, 2)
	
func setWestInsideCornerTile(tileCoord):
	_borderTilemap.set_cellv(tileCoord, 0)
	
#func setFurnitureTile(tileCoord):
#	_furnitureTilemap.set_cellv(tileCoord, randi() % 50)
	
	
	
