extends Node2D

@export var width: int = 50
@export var height: int = 50
@export var center: Vector2i = Vector2.ZERO

var half_size = Vector2i(width, height) / 2

@export var frequency: float = 0.1
@export var threshold: float = 0.5

@onready var tileMap: TileMap = $TileMap
@onready var grassContainers: Node2D = $YSort/Grass

var noise : FastNoiseLite = FastNoiseLite.new()
var rng = RandomNumberGenerator.new()

var grass_texture = preload("res://AssetsRessources/grass01.tres")
var grass_scene = preload("res://AssetsRessources/grass01.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	print("layer 0 : %s" % tileMap.get_layer_name(0))
	generate_map()

func generate_map():
	noise.seed = randi()
	rng.seed = noise.seed
	noise.frequency = frequency
	print("generate_map")
#	var half_size = Vector2i(width, height) / 2
#
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
	
	generate_grass()
	
func generate_grass():
	noise.frequency = frequency * 2.;
	noise.offset = Vector3(100, 100, 0)
	for x in width:
		for y in height:
			var pos = center + Vector2i(x, y) - half_size
			
			var data: TileData = tileMap.get_cell_tile_data(0, pos)
			if data != null:
				var grassSpawnable: bool = data.get_custom_data("grassSpawnable")
				
				if grassSpawnable:
					var rand = (noise.get_noise_2d(pos.x, pos.y) + 1.) / 2.
					
					if rand > threshold*1.5:
						var world_pos = tileMap.to_global(tileMap.map_to_local(pos)) + Vector2(rng.randf_range(-5., 5.), rng.randf_range(-5., 5.))
						
						var grass_node = grass_scene.instantiate()
						grass_node.position = world_pos
						grassContainers.add_child(grass_node)
	#					grass_spritetileMap.set_cell(1, pos, 0, Vector2i(6, 6))

func _input(event):
	if event.is_action_pressed("ui_accept"):
		generate_map()
		generate_grass()
	
