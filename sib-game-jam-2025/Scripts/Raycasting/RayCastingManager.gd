extends Node
@onready var cards_hand: CardHand = $"../CardsHand"
@onready var camera_3d: Camera3D = $"../Camera3D"

func example():
	# перед этим нужно задать нужный колижн layer(!!!)
	# layer - к чему объект принадлежит
	# mask - с чем взаимодействует
	# $Card.collision_layer = CollisionLayers.Layer.PLAYER | CollisionLayers.CARD
	
	var collision_mask =  CollisionLayers.PLAYER | CollisionLayers.CARD
	var obj = find_raycast_object(camera_3d, collision_mask)

func _physics_process(delta):
	# 0xFFFFFFFF - реагировать на всё
	if (camera_3d != null):
		var test = find_raycast_object(camera_3d, 0xFFFFFFFF)
		if (test != null):
			print(test.name)

func _ready():	
	print("[RAY CASTING] READY")

func find_raycast_object(from_node: Camera3D, mask: int) -> Object:
	var mouse_screen_pos = get_viewport().get_mouse_position()
	print("[RAY CASTING] current mouse position: ", mouse_screen_pos)
	
	var ray_origin = from_node.project_ray_origin(mouse_screen_pos)
	var max_distance = 1000;
	var ray_end = ray_origin + from_node.project_ray_normal(mouse_screen_pos) * max_distance
	
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, mask)
	
	var space_state = from_node.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(ray_query)
	
	if not result:
		print("[RAY CASTING] Raycast failed. Possible reasons:")
		print("- Camera active:", from_node.is_current())
		print("- Ray origin:", ray_origin)
		print("- Ray end:", ray_end)
		print("- Mask:", mask)
	#	print("- Objects in scene:", get_tree().get_nodes_in_group("physics_objects").size())
	
	return result.collider if result else null
