extends CharacterBody3D


const PI2 = PI * 2.0
const PI_2 = PI / 2.0
const FOV_SCALAR = 1.5
const FOV_INERTIA_SCALAR = 8.0
const GROUND_INERTIA_SCALAR = 7.0
const AIR_INERTIA_SCALAR = 3.0

@export_category("Camera Controls")
@export var BASE_FOV = 75.0
@export var SENSITIVITY = 0.003

@export_category("Character Controls")
@export var WALK_SPEED = 5.0
@export var SPRINT_SPEED = 8.0
@export var MAX_SPEED = 16.0
@export var JUMP_VELOCITY = 4.5

@export_category("Headbob Parameters")
@export var BOB_VERTICAL_FREQUENCY = 2.0
@export var BOB_HORIZONTAL_FREQUENCY = 1.0
@export var BOB_AMPLITUDE = 0.08

var BOB_VERTICAL_CAP = PI2 * BOB_VERTICAL_FREQUENCY
var BOB_HORIZONTAL_CAP = PI2 * BOB_HORIZONTAL_FREQUENCY

# Get the gravity from the project settings to be synced with RigidBody nodes.
var GRAVITY: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var t_bob_vertical: float = 0.0
var t_bob_horizontal: float = 0.0
var speed: float = 0.0

@onready var head = $player_hitbox/player_head
@onready var camera = $player_hitbox/player_head/player_camera


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI_2, PI_2)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()
	elif event.is_action_pressed("reset"):
		transform.origin = Vector3.ZERO


func _physics_process(delta: float) -> void:
	var on_floor = is_on_floor()
	# Add the gravity.
	if not on_floor:
		velocity.y -= GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and on_floor:
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if on_floor:
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			var lerp_step = delta * GROUND_INERTIA_SCALAR
			velocity.x = lerp(velocity.x, direction.x * speed, lerp_step)
			velocity.z = lerp(velocity.z, direction.z * speed, lerp_step)
	else:
		var lerp_step = delta * AIR_INERTIA_SCALAR
		velocity.x = lerp(velocity.x, direction.x * speed, lerp_step)
		velocity.z = lerp(velocity.z, direction.z * speed, lerp_step)

	var velocity_mag = velocity.length()

	# Head bob
	var t_bob = velocity_mag * float(on_floor) * delta
	t_bob_vertical += t_bob
	if t_bob_vertical >= BOB_VERTICAL_CAP:
		t_bob_vertical = 0.0
	t_bob_horizontal += t_bob
	if t_bob_horizontal >= BOB_HORIZONTAL_CAP:
		t_bob_horizontal = 0.0
	camera.transform.origin = _headbob()

	# FOV
	var velocity_clamped = clamp(velocity_mag, 0.0, MAX_SPEED)
	var target_fov = BASE_FOV + FOV_SCALAR * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * FOV_INERTIA_SCALAR)

	move_and_slide()


func _headbob() -> Vector3:
	var pos = Vector3.ZERO
	pos.x = cos(t_bob_horizontal * BOB_HORIZONTAL_FREQUENCY) * BOB_AMPLITUDE
	pos.y = sin(t_bob_vertical * BOB_VERTICAL_FREQUENCY) * BOB_AMPLITUDE
	return pos
