extends Control

var resources: int = 0

@onready var resources_label = $RootPanel/MainColumn/ResourcesLabel
@onready var slot1 = $RootPanel/MainColumn/Slot1
@onready var slot2 = $RootPanel/MainColumn/Slot2
@onready var slot3 = $RootPanel/MainColumn/Slot3

func _ready() -> void:
	setup_window()
	var slots = [slot1, slot2, slot3]

	for slot in slots:
		slot.harvested.connect(_on_slot_harvested)
		slot.unlock_requested.connect(_on_slot_unlock_requested)
		slot.upgrade_requested.connect(_on_slot_upgrade_requested)

	update_ui()

func setup_window() -> void:
	var screen_id := DisplayServer.window_get_current_screen()
	var usable_rect := DisplayServer.screen_get_usable_rect(screen_id)

	var target_width := int(usable_rect.size.x / 5)
	var target_height := usable_rect.size.y

	var target_size := Vector2i(target_width, target_height)
	var target_position := Vector2i(
		usable_rect.position.x + usable_rect.size.x - target_width,
		usable_rect.position.y
	)

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(target_size)
	DisplayServer.window_set_position(target_position)

	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)

func _on_slot_harvested(amount: int) -> void:
	resources += amount
	update_ui()

func _on_slot_unlock_requested(slot: PanelContainer, cost: int) -> void:
	if resources >= cost:
		resources -= cost
		slot.unlock()
		update_ui()

func _on_slot_upgrade_requested(slot: PanelContainer, cost: int) -> void:
	if resources >= cost:
		resources -= cost
		slot.upgrade()
		update_ui()

func update_ui() -> void:
	resources_label.text = "Resources: %d" % resources
