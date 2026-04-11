extends Control

var resources: int = 0

@onready var resources_label = $RootPanel/MainColumn/ResourcesLabel
@onready var slot1 = $RootPanel/MainColumn/Slot1
@onready var slot2 = $RootPanel/MainColumn/Slot2
@onready var slot3 = $RootPanel/MainColumn/Slot3

func _ready() -> void:
	slot1.harvested.connect(_on_slot_harvested)
	slot2.harvested.connect(_on_slot_harvested)
	slot3.harvested.connect(_on_slot_harvested)
	update_ui()

func _on_slot_harvested(amount: int) -> void:
	resources += amount
	update_ui()

func update_ui() -> void:
	resources_label.text = "Resources: %d" % resources
