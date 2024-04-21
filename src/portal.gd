extends Node3D

@export var PLAYER_CAMERA: Camera3D
@export var LINKED_PORTAL: Node3D

@onready var viewport: SubViewport = $viewport
@onready var portal_camera: Camera3D = $viewport/portal_camera
@onready var portal: CSGBox3D = $portal_plane

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var main_viewport = get_viewport()
	var player_camera = main_viewport.get_camera_3d()
	var linked_portal = LINKED_PORTAL.get_node("portal_plane")
	var m = linked_portal.global_transform * portal.global_transform.affine_inverse() * player_camera.global_transform

	portal_camera.global_transform = m
	portal_camera.fov = PLAYER_CAMERA.fov
	portal_camera.cull_mask = PLAYER_CAMERA.cull_mask

	viewport.size = main_viewport.get_visible_rect().size
	viewport.msaa_3d = main_viewport.msaa_3d
	viewport.screen_space_aa = main_viewport.screen_space_aa
	viewport.use_taa = main_viewport.use_taa
	viewport.use_debanding = main_viewport.use_debanding
	viewport.use_occlusion_culling = main_viewport.use_occlusion_culling
	viewport.mesh_lod_threshold = main_viewport.mesh_lod_threshold
