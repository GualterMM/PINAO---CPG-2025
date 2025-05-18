extends CanvasLayer

@onready var overlay = $BlurOverlay  # TextureRect with centered radial alpha texture

func set_active(active: bool) -> void:
	visible = active
