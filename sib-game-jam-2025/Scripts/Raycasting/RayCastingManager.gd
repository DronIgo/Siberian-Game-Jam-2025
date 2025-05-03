extends Node
@onready var cards_hand: CardHand = $"../CardsHand"
@onready var camera_3d: Camera3D = $"../Camera3D"

func _physics_process(delta: float) -> void:
	var card = find_raycast_player_card()
	if card:
		print(Card.CARD_COLOR.keys()[card.base_card.color])

func find_raycast_object(mask: int) -> Object:
	var mouse_screen_pos = get_viewport().get_mouse_position()
	
	var ray_origin = camera_3d.project_ray_origin(mouse_screen_pos)
	var max_distance = 1000;
	var ray_end = ray_origin + camera_3d.project_ray_normal(mouse_screen_pos) * max_distance
	
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, mask)
	
	var space_state = camera_3d.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(ray_query)
	
	return result.collider if result else null

func find_raycast_player_card() -> Card3D:
	var body = find_raycast_object(RaycastLayers.LAYER.PLAYER_CARDS)
	if !body:
		return null
	return body.get_parent() as Card3D

func find_raycast_line_card() -> Card3D:
	var body = find_raycast_object(RaycastLayers.LAYER.ENEMY_CARDS)
	if !body:
		return null
	return body.get_parent() as Card3D
