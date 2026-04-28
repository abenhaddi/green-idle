extends Control

var resources: int = 0

@onready var resources_label = $RootPanel/MainColumn/ResourcesLabel
@onready var slot1 = $RootPanel/MainColumn/Slot1
@onready var slot2 = $RootPanel/MainColumn/Slot2
@onready var slot3 = $RootPanel/MainColumn/Slot3

func _ready() -> void:
	var slots = [slot1, slot2, slot3]

	for slot in slots:
		slot.harvested.connect(_on_slot_harvested)
		slot.unlock_requested.connect(_on_slot_unlock_requested)
		slot.upgrade_requested.connect(_on_slot_upgrade_requested)

	update_ui()

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
