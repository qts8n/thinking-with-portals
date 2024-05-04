extends Node3D

@export var LINKED_PORTAL: Node3D
@export var DEBUG_COLOR: Color = Color.MAGENTA

@onready var viewport: SubViewport = $portal_viewport
@onready var portal_camera: Camera3D = $portal_viewport/portal_camera
@onready var portal_camera_mesh: = $portal_viewport/portal_camera/debug_mesh
@onready var portal: CSGBox3D = $portal_plane

var _portal_radius: float

func _ready() -> void:
	portal_camera_mesh.mesh.material.albedo_color = DEBUG_COLOR

	_portal_radius = max(portal.size.x, portal.size.y, portal.size.z)

	if Engine.is_editor_hint():
		return

	var main_viewport = get_viewport()
	var world = main_viewport.world_3d
	if not world or not world.environment:
		return

	# The tonemap must be set to linear,
	# so the tonemap won't be applied twice
	portal_camera.environment = world.environment.duplicate()
	portal_camera.environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var main_viewport = get_viewport()
	var player_camera = main_viewport.get_camera_3d()
	if not player_camera:
		return

	# Calculate transform of the portal camera
	# relatively to the linked portal position
	# based on the player camera transform
	# relatively to the current portal position
	var linked_portal = LINKED_PORTAL.get_node("portal_plane")
	var m = linked_portal.global_transform * portal.global_transform.affine_inverse() * player_camera.global_transform

	# Update portal camera attributes based on the player camera
	portal_camera.global_transform = m

	var near = portal_camera.global_position.distance_to(linked_portal.global_position) - _portal_radius
	near = max(0.001, near)
	portal_camera.set_perspective(player_camera.fov, near, player_camera.far)
	#portal_camera.cull_mask = player_camera.cull_mask

	# Update camera viewport attributes based on the main viewport
	viewport.size = main_viewport.size
	viewport.msaa_3d = main_viewport.msaa_3d
	viewport.screen_space_aa = main_viewport.screen_space_aa
	viewport.use_taa = main_viewport.use_taa
	viewport.use_debanding = main_viewport.use_debanding
	viewport.use_occlusion_culling = main_viewport.use_occlusion_culling
	viewport.mesh_lod_threshold = main_viewport.mesh_lod_threshold
