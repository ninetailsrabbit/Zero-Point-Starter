extends Node


#region Interactables
signal interactable_focused(interactor);
signal interactable_unfocused(interactor);
signal interactable_interacted(interactor);
signal interactable_canceled_interaction(interactor);
signal interactable_interaction_limit_reached(interactable: Interactable3D);
#endregion

#region Controllers
signal controller_connected(device: int, controller_name: String)
signal controller_disconnected(device: int, controller_name: String)
#endregion

#region Scenes
signal scene_transition_requested(next_scene_path)
signal scene_transition_finished(next_scene_path)
#endregion
