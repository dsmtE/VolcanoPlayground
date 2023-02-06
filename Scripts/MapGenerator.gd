extends Node2D

@export var width: int = 50
@export var height: int = 50
@export var center: Vector2i = Vector2.ZERO

@export var frequency: float = 0.1
@export var threshold: float = 0.5

@onready var tileMap: TileMap = $TileMap

var noise : FastNoiseLite = FastNoiseLite.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	noise.seed = randi()
	noise.frequency = frequency
	print("layer 0 : %s" % tileMap.get_layer_name(0))

	generate_map()

func generate_map():
	print("generate_map")
	var half_size = Vector2i(width, height) / 2
	
	var dirt_cells_pos: Array[Vector2i] = []
	var all_cels_pos: Array[Vector2i] = []
	for x in width:
		for y in height:
			var pos = center + Vector2i(x, y) - half_size
			var rand = (noise.get_noise_2d(pos.x, pos.y) + 1.) / 2.
			
			# Place manually cells
			# var tile_coordinate = Vector2i(1, 1) if rand > threshold else Vector2i(5, 2)
			# tileMap.set_cell(0, pos, 0, tile_coordinate, 0)
			
			# Try use terrain
			if rand > threshold:
				dirt_cells_pos.append(pos)
			all_cels_pos.append(pos)
	tileMap.clear()
	tileMap.set_cells_terrain_connect(0, all_cels_pos, 0, 0)
	tileMap.set_cells_terrain_connect(0, dirt_cells_pos, 0, 1)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		noise.seed = randi()
		generate_map()
	
