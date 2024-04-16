extends Node3D


@onready var grass_portal = $grass_platform/grass_portal/portal_plane
@onready var rock_portal = $rock_platform/rock_portal/portal_plane

@onready var player_camera = $player/player_hitbox/player_head/player_camera
@onready var portal_camera = $portal_camera


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
