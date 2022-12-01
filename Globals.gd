extends Node2D

const PLAYER_SPEED = 500
const BULLET_SPEED = 2000
const CAMERA_DEAD_ZONE = 160
const DIRECTIONS = [ [0,-1] , [-1,0] , [0,1] , [1,0] ]
const DIRECTIONS_VEC = [ Vector2(0,-1) , Vector2(-1,0) , Vector2(0,1) , Vector2(1,0) ]
const WALL_LIST = ["WallN","WallW","WallS","WallE"]
const VERBOSE_DIRECTIONS = ["NORTH","WEST","SOUTH","EAST"]
const OPPOSITE_WALL_LIST = ["WallS","WallE","WallN","WallW"]
const WALL_DOOR_COORD = {
#	"WallN" : [Vector2(5, 0), Vector2(6, 0)],
#	"WallW" : [Vector2(0, 4)],
#	"WallS" : [Vector2(5, 7), Vector2(6, 7)],
#	"WallE" : [Vector2(11, 4)]
	"WallN" : [Vector2(4, 0), Vector2(5, 0)],
	"WallW" : [Vector2(0, 2)],
	"WallS" : [Vector2(4, 5), Vector2(5, 5)],
	"WallE" : [Vector2(9, 2)]
}
const ROOM_WIDTH = 1280 #1536
const ROOM_HEIGHT = 768 #1024
const LARGE_ROOM_CHANCE = 0.4
const DISCO_ROOM_CHANCE = 0.4
const FURNITURE_CHANCE = 0.15
const DISCO_ROOM_COLORS = [Color(.39,.68,.21),Color(1,1,.32),Color(.98,.6,.07),Color(1,.15,.07),Color(.51,0,.65),Color(.07,.27,.98),Color(.0,.0,.0)]
const NPC_SPEED_MIN = 75
const NPC_SPEED_MAX = 200
const NPC_ALERT_SPEED_MULTIPLIER = 2.75
const NPC_LOCATION_VARIATION = 512
const NPC_CHANCES_OF_LEAVING_ROOM = 0.25
const NPC_VISON = 500
const MAX_GAME_TIMER = 100.0
const MIN_GAME_TIMER = 30.0
enum STATES {IDLE, WANDER, ALERT, DEAD}

var currentLevel = 1
var DETECTION_MULTIPLIER = 1 + currentLevel * 0.05

const NPC_LIST = [
	{
		"index" : 0,
		"name" : "purple owl in a cyan tunic",
	},
	{ 
		"index" : 1,
		"name" : "white owl wearing a red tunic",
	},
	{ 
		"index" : 2,
		"name" : "brown owl in a green tunic",
	},
	{ 
		"index" : 3,
		"name" : "mauve cat wearing a green tunic",
	},
	{ 
		"index" : 4,
		"name" : "purple cat in a pink tunic",
	},
	{ 
		"index" : 5,
		"name" : "brown cat wearing a blue tunic",
	},
	{ 
		"index" : 6,
		"name" : "brown goat in a green tunic",
	},
	{ 
		"index" : 7,
		"name" : "purple goat in an orange tunic",
	},
	{ 
		"index" : 8,
		"name" : "grey goat in a blue tunic",
	},
	{ 
		"index" : 9,
		"name" : "grey mouse in a orange tunic",
	},
	{ 
		"index" : 10,
		"name" : "white mouse in a green tunic",
	},
	{ 
		"index" : 11,
		"name" : "black mouse in a purple tunic",
	},
	{ 
		"index" : 12,
		"name" : "white rabbit in a red tunic",
	},
	{ 
		"index" : 13,
		"name" : "brown rabbit in a green tunic",
	},
	{ 
		"index" : 14,
		"name" : "blue rabbit in a blue tunic",
	},
	{ 
		"index" : 15,
		"name" : "light green alligator in a green swimsuit",
	},
	{ 
		"index" : 16,
		"name" : "green alligator in a mauve swimsuit",
	},
	{ 
		"index" : 17,
		"name" : "dark green alligator in a purple swimsuit",
	},
	{ 
		"index" : 18,
		"name" : "white seagull in a blue outfit",
	},
	{ 
		"index" : 19,
		"name" : "grey seagull in a green outfit",
	},
	{ 
		"index" : 20,
		"name" : "dark seagull in a red outfit",
	},
	{ 
		"index" : 21,
		"name" : "purple cobra in a green outfit",
	},
	{ 
		"index" : 22,
		"name" : "green snake in a brown outfit",
	},
	{ 
		"index" : 23,
		"name" : "red snake in a blue outfit",
	},
	{ 
		"index" : 24,
		"name" : "grey fox in a grey outfit",
	},
	{ 
		"index" : 25,
		"name" : "brown fox in a blue outfit",
	},
	{ 
		"index" : 26,
		"name" : "dark fox in a green outfit",
	},
	{ 
		"index" : 27,
		"name" : "green turle in a red jacket",
	},
	{ 
		"index" : 28,
		"name" : "orange turle in a purple jacket",
	},
	{ 
		"index" : 29,
		"name" : "green turle in a blue jacket",
	},
	{ 
		"index" : 30,
		"name" : "pink pig in a green suit",
	},
	{ 
		"index" : 31,
		"name" : "dark pig in a fushia suit",
	},
	{ 
		"index" : 32,
		"name" : "brown pig in a blue suit",
	},
]
