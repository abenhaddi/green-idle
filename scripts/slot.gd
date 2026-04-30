extends PanelContainer

signal empty_slot_selected(slot: PanelContainer)
signal unlock_requested(slot: PanelContainer, cost: int)
signal harvested(amount: int)

enum SlotState { LOCKED, EMPTY, GROWING, READY }

@export var starts_unlocked: bool = false
@export var unlock_cost: int = 10

var state: SlotState
var current_time: float = 0.0

var plant_name: String = ""
var grow_time: float = 0.0
var reward: int = 0

@onready var status_label = $Column/StatusLabel
@onready var progress_bar = $Column/ProgressBar
@onready var action_button = $Column/ActionButton

func _ready() -> void:
	state = SlotState.EMPTY if starts_unlocked else SlotState.LOCKED
	reset_plant_data()
	update_ui()

func _process(delta: float) -> void:
	if state != SlotState.GROWING:
		return

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
			empty_slot_selected.emit(self)

		SlotState.GROWING:
			return

		SlotState.READY:
			harvest()

func unlock() -> void:
	state = SlotState.EMPTY
	current_time = 0.0
	reset_plant_data()
	update_ui()

func plant(new_plant_name: String, new_grow_time: float, new_reward: int) -> void:
	if state != SlotState.EMPTY:
		return

	plant_name = new_plant_name
	grow_time = max(new_grow_time, 0.1)
	reward = new_reward
	current_time = 0.0
	state = SlotState.GROWING
	update_ui()

func harvest() -> void:
	if state != SlotState.READY:
		return

	var earned_resources := reward

	state = SlotState.EMPTY
	current_time = 0.0
	reset_plant_data()

	harvested.emit(earned_resources)
	update_ui()

func reset_plant_data() -> void:
	plant_name = ""
	grow_time = 0.0
	reward = 0

func update_ui() -> void:
	match state:
		SlotState.LOCKED:
			status_label.text = "Bloqueado"
			action_button.text = "Desbloquear (%d€)" % unlock_cost
			action_button.disabled = false
			progress_bar.value = 0

		SlotState.EMPTY:
			status_label.text = "Parcela vacía"
			action_button.text = "Plantar"
			action_button.disabled = false
			progress_bar.value = 0

		SlotState.GROWING:
			status_label.text = "%s creciendo" % plant_name
			action_button.text = "Creciendo..."
			action_button.disabled = true
			progress_bar.value = (current_time / grow_time) * 100.0

		SlotState.READY:
			status_label.text = "%s lista" % plant_name
			action_button.text = "Recolectar"
			action_button.disabled = false
			progress_bar.value = 100
