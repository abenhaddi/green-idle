extends Control

var money: int = 20
var resources: int = 0
var selected_slot: PanelContainer = null

var plants = [
	{
		"name": "Lechuga",
		"unlock_cost": 0,
		"grow_time": 5.0,
		"reward": 3,
		"unlocked": true
	},
	{
		"name": "Zanahoria",
		"unlock_cost": 25,
		"grow_time": 8.0,
		"reward": 7,
		"unlocked": false
	},
	{
		"name": "Tomate",
		"unlock_cost": 60,
		"grow_time": 12.0,
		"reward": 15,
		"unlocked": false
	}
]

@onready var garden_screen = $RootPanel/ScreenContainer/GardenScreen
@onready var plant_inventory_screen = $RootPanel/ScreenContainer/PlantInventoryScreen

@onready var money_label = $RootPanel/ScreenContainer/GardenScreen/Header/MoneyLabel
@onready var resources_label = $RootPanel/ScreenContainer/GardenScreen/Header/ResourcesLabel

@onready var slot1 = $RootPanel/ScreenContainer/GardenScreen/GardenPanel/GardenGrid/Slot1
@onready var slot2 = $RootPanel/ScreenContainer/GardenScreen/GardenPanel/GardenGrid/Slot2
@onready var slot3 = $RootPanel/ScreenContainer/GardenScreen/GardenPanel/GardenGrid/Slot3
@onready var slot4 = $RootPanel/ScreenContainer/GardenScreen/GardenPanel/GardenGrid/Slot4
@onready var slot5 = $RootPanel/ScreenContainer/GardenScreen/GardenPanel/GardenGrid/Slot5
@onready var slot6 = $RootPanel/ScreenContainer/GardenScreen/GardenPanel/GardenGrid/Slot6

@onready var plant_button_1 = $RootPanel/ScreenContainer/PlantInventoryScreen/Plant1Button
@onready var plant_button_2 = $RootPanel/ScreenContainer/PlantInventoryScreen/Plant2Button
@onready var plant_button_3 = $RootPanel/ScreenContainer/PlantInventoryScreen/Plant3Button
@onready var back_button = $RootPanel/ScreenContainer/PlantInventoryScreen/BackButton

@onready var sell_resources_button = $RootPanel/ScreenContainer/GardenScreen/SellResourcesButton

func _ready() -> void:
	setup_window()
	setup_slots()
	setup_inventory()
	show_garden()
	update_ui()

func setup_slots() -> void:
	var slots = [slot1, slot2, slot3, slot4, slot5, slot6]

	for slot in slots:
		slot.empty_slot_selected.connect(_on_empty_slot_selected)
		slot.unlock_requested.connect(_on_slot_unlock_requested)
		slot.harvested.connect(_on_slot_harvested)

func setup_inventory() -> void:
	plant_button_1.pressed.connect(func(): select_plant(0))
	plant_button_2.pressed.connect(func(): select_plant(1))
	plant_button_3.pressed.connect(func(): select_plant(2))
	back_button.pressed.connect(_on_back_button_pressed)
	sell_resources_button.pressed.connect(_on_sell_resources_button_pressed)

func _on_empty_slot_selected(slot) -> void:
	selected_slot = slot
	show_inventory()

func select_plant(index: int) -> void:
	if selected_slot == null:
		return

	var plant = plants[index]

	if plant["unlocked"]:
		selected_slot.plant(
			plant["name"],
			plant["grow_time"],
			plant["reward"]
		)

		selected_slot = null
		show_garden()
		update_ui()
	else:
		if money >= plant["unlock_cost"]:
			money -= plant["unlock_cost"]
			plant["unlocked"] = true
			update_ui()

func _on_slot_unlock_requested(slot: PanelContainer, cost: int) -> void:
	if money >= cost:
		money -= cost
		slot.unlock()
		update_ui()

func _on_slot_harvested(amount: int) -> void:
	resources += amount
	update_ui()

func _on_sell_resources_button_pressed() -> void:
	if resources <= 0:
		return

	money += resources
	resources = 0
	update_ui()

func _on_back_button_pressed() -> void:
	selected_slot = null
	show_garden()

func show_garden() -> void:
	garden_screen.visible = true
	plant_inventory_screen.visible = false

func show_inventory() -> void:
	garden_screen.visible = false
	plant_inventory_screen.visible = true
	update_ui()

func update_ui() -> void:
	money_label.text = "Dinero: %d€" % money
	resources_label.text = "Recursos: %d" % resources

	update_plant_button(plant_button_1, 0)
	update_plant_button(plant_button_2, 1)
	update_plant_button(plant_button_3, 2)

	sell_resources_button.text = "Vender recursos (+%d€)" % resources
	sell_resources_button.disabled = resources <= 0

func update_plant_button(button: Button, index: int) -> void:
	var plant = plants[index]

	if plant["unlocked"]:
		button.text = "%s\nTiempo: %.0fs\nProduce: %d\nPlantar" % [
			plant["name"],
			plant["grow_time"],
			plant["reward"]
		]
		button.disabled = false
	else:
		button.text = "%s bloqueada\nDesbloquear: %d€" % [
			plant["name"],
			plant["unlock_cost"]
		]
		button.disabled = money < plant["unlock_cost"]

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
