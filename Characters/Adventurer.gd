extends CharacterBody2D

@export var move_speed: float = 100.0
@export var starting_direction: Vector2 = Vector2(0, 1)

@onready var animation_tree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

func _ready():
	update_animations_parameters(starting_direction)

func get_input_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up"),
	).normalized()
	
func _physics_process(_delta):
	var input_direction = get_input_direction()
	
	update_animations_parameters(input_direction)
	
	velocity = input_direction * move_speed
	
	change_animation_state(input_direction)
	move_and_slide()
	
	
func update_animations_parameters(input_direction: Vector2):
	if(input_direction != Vector2.ZERO):
		animation_tree.set("parameters/Idle/blend_position", input_direction.x)
		animation_tree.set("parameters/Run/blend_position", input_direction.x)

func change_animation_state(move_input: Vector2):
	if move_input == Vector2.ZERO:
		state_machine_travel_if_needed("Idle")
	else: 
		state_machine_travel_if_needed("Run")

func state_machine_travel_if_needed(to_node: StringName):
	if state_machine.get_current_node() != to_node:
			state_machine.travel(to_node)

