extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var camera_reverse_pan_speed = 0.01
var max_horiontal_amp = 0.2

@onready var camera = $camera_mount
var camera_rotation_y = 0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func apply_camera_reverse_pan(mouse_motion_event: InputEventMouseMotion):
	var rotation_y_delta = deg_to_rad(-mouse_motion_event.relative.x*camera_reverse_pan_speed)

	# Apply damping only if we move in the same direction to reach the max bound
	if (rotation_y_delta * camera_rotation_y) > 0:
		var damping_factor = 1-pow(camera_rotation_y/max_horiontal_amp,2)
		rotation_y_delta *= damping_factor

	camera_rotation_y = clamp(
			camera_rotation_y + rotation_y_delta,
			-max_horiontal_amp,
			max_horiontal_amp)
	camera.rotation.y = camera_rotation_y
		
func _input(event):
	if event is InputEventMouseMotion:
		
		apply_camera_reverse_pan(event)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
