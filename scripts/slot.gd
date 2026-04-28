extends PanelContainer

signal harvested(amount: int)
signal unlock_requested(slot: PanelContainer, cost: int)
signal upgrade_requested(slot: PanelContainer, cost: int)

enum SlotState { LOCKED, EMPTY, GROWING, READY }

@export var starts_unlocked: bool = false
@export var unlock_cost: int = 0
@export var grow_time: float = 10.0
@export var base_reward: int = 1
@export var upgrade_cost: int = 10

var state: SlotState
var current_time: float = 0.0
var plant_level: int = 1

@onready var status_label = $Column/StatusLabel
@onready var progress_bar = $Column/ProgressBar
@onready var action_button = $Column/ActionButton
@onready var upgrade_button = $Column/UpgradeButton

func _ready() -> void:
	state = SlotState.EMPTY if starts_unlocked else SlotState.LOCKED
	update_ui()

func _process(delta: float) -> void:
	if state == SlotState.GROWING:
		current_time += delta

		if current_time >= grow_time:
			current_time = grow_time
			state = SlotState.READY

		update_ui()

func _on_action_button_pressed() -> void:
	match state:
		SlotState.LOCKED:
			unlock_requested.emit(self, unlock_cost)
		SlotState.EMPTY:
			plant()
		SlotState.GROWING:
			pass
		SlotState.READY:
			harvest()

func _on_upgrade_button_pressed() -> void:
	if state != SlotState.LOCKED:
		upgrade_requested.emit(self, upgrade_cost)

func unlock() -> void:
	state = SlotState.EMPTY
	current_time = 0.0
	update_ui()

func upgrade() -> void:
	plant_level += 1
	upgrade_cost = int(upgrade_cost * 1.75)
	update_ui()

func plant() -> void:
	state = SlotState.GROWING
	current_time = 0.0
	update_ui()

func harvest() -> void:
	state = SlotState.EMPTY
	current_time = 0.0
	harvested.emit(get_reward())
	update_ui()

func get_reward() -> int:
	return base_reward * plant_level

func update_ui() -> void:
	match state:
		SlotState.LOCKED:
			status_label.text = "Locked Slot"
			action_button.text = "Unlock (%d)" % unlock_cost
			action_button.disabled = false
			upgrade_button.visible = false
			progress_bar.value = 0

		SlotState.EMPTY:
			status_label.text = "Level %d plant (+%d)" % [plant_level, get_reward()]
			action_button.text = "Plant"
			action_button.disabled = false
			upgrade_button.visible = true
			upgrade_button.text = "Upgrade (%d)" % upgrade_cost
			progress_bar.value = 0

		SlotState.GROWING:
			status_label.text = "Growing... (+%d)" % get_reward()
			action_button.text = "Waiting"
			action_button.disabled = true
			upgrade_button.visible = true
			upgrade_button.text = "Upgrade (%d)" % upgrade_cost
			progress_bar.value = (current_time / grow_time) * 100.0

		SlotState.READY:
			status_label.text = "Ready (+%d)" % get_reward()
			action_button.text = "Harvest"
			action_button.disabled = false
			upgrade_button.visible = true
			upgrade_button.text = "Upgrade (%d)" % upgrade_cost
			progress_bar.value = 100
