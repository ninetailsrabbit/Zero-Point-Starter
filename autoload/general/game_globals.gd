extends Node


#region Physics layers
const world_collision_layer: int = 1
const player_collision_layer: int = 2
const enemies_collision_layer: int = 4
const interactables_collision_layer: int = 8
const throwables_collision_layer: int = 16
const hitboxes_collision_layer: int = 32
const shakeables_collision_layer: int = 64
#endregion


#region General helpers
## Example with lambda -> Utilities.delay_func(func(): print("test"), 1.5)
## Example with arguments -> Utilities.delay_func(print_text.bind("test"), 2.0)
func delay_func(callable: Callable, time: float, deferred: bool = true):
	if callable.is_valid():
		await get_tree().create_timer(time).timeout
		
		if deferred:
			callable.call_deferred()
		else:
			callable.call()

#endregion

#region Parallax helpers
func adapt_parallax_background_to_horizontal_viewport(parallax_background: ParallaxBackground, viewport: Rect2 = get_window().get_visible_rect()) -> void:	
	for parallax_layer: ParallaxLayer in NodeTraversal.find_nodes_of_type(parallax_background, ParallaxLayer.new()):
		if parallax_layer.get_child(0) is Sprite2D:
			var sprite: Sprite2D = parallax_layer.get_child(0) as Sprite2D
			var texture_size = sprite.texture.get_size()
			sprite.scale = Vector2.ONE * (viewport.size.y / texture_size.y)
			
			parallax_layer.motion_mirroring = Vector2(texture_size.x * sprite.scale.x, 0)
		
		
func adapt_parallax_background_to_vertical_viewport(parallax_background: ParallaxBackground, viewport: Rect2 = get_window().get_visible_rect()) -> void:	
	for parallax_layer: ParallaxLayer in NodeTraversal.find_nodes_of_type(parallax_background, ParallaxLayer.new()):
		if parallax_layer.get_child(0) is Sprite2D:
			var sprite: Sprite2D = parallax_layer.get_child(0) as Sprite2D
			var texture_size = sprite.texture.get_size()
			sprite.scale = Vector2.ONE * (viewport.size.x / texture_size.x)
			
			parallax_layer.motion_mirroring = Vector2(0, texture_size.y * sprite.scale.y)


func adapt_parallax_to_horizontal_viewport(parallax: Parallax2D, viewport: Rect2 = get_window().get_visible_rect()) -> void:	
	if parallax.get_child(0) is Sprite2D:
		var sprite: Sprite2D = parallax.get_child(0) as Sprite2D
		var texture_size = sprite.texture.get_size()
		sprite.scale = Vector2.ONE * (viewport.size.y / texture_size.y)
		
		parallax.repeat_size = Vector2(texture_size.x * sprite.scale.x, 0)
	

func adapt_parallax_to_vertical_viewport(parallax: Parallax2D, viewport: Rect2 = get_window().get_visible_rect()) -> void:	
	if parallax.get_child(0) is Sprite2D:
		var sprite: Sprite2D = parallax.get_child(0) as Sprite2D
		var texture_size = sprite.texture.get_size()
		sprite.scale = Vector2.ONE * (viewport.size.x / texture_size.x)
		
		parallax.repeat_size = Vector2(0, texture_size.y * sprite.scale.y)
#endregion
