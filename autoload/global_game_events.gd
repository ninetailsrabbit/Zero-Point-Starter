extends Node


#region Interactables
signal interactable_focused(interactor);
signal interactable_unfocused(interactor);
signal interactable_interacted(interactor);
signal interactable_canceled_interaction(interactor);
signal interactable_interaction_limit_reached(interactable: Interactable3D);
#endregion
