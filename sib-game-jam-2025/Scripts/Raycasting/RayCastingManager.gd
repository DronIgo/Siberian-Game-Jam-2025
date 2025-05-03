extends Node
@onready var cards_hand: CardHand = $"../CardsHand"
@onready var camera_3d: Camera3D = $"../Camera3D"

func find_raycast_object(mask: int) -> Object:
	var mouse_screen_pos = get_viewport().get_mouse_position()
	print("[RAY CASTING] current mouse position: ", mouse_screen_pos)
	
	var ray_origin = camera_3d.project_ray_origin(mouse_screen_pos)
	var max_distance = 1000;
	var ray_end = ray_origin + camera_3d.project_ray_normal(mouse_screen_pos) * max_distance
	
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, mask)
	
	var space_state = camera_3d.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(ray_query)
	
	if not result:
		print("[RAY CASTING] Raycast failed. Possible reasons:")
		print("- Camera active:", camera_3d.is_current())
		print("- Ray origin:", ray_origin)
		print("- Ray end:", ray_end)
		print("- Mask:", mask)
	
	return result.collider if result else null

func find_raycast_player_card() -> Card3D:
	var body = find_raycast_object(RaycastLayers.LAYER.PLAYER_CARDS)
	if !body:
		return null
	return body.get_node("../../Card") as Card3D

func find_raycast_line_card() -> Card3D:
	var body = find_raycast_object(RaycastLayers.LAYER.ENEMY_CARDS)
	if !body:
		return null
	return body.get_node("../../Card") as Card3D
