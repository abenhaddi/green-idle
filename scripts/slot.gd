extends PanelContainer

signal harvested(amount)

enum SlotState { EMPTY, GROWING, READY }

var state: SlotState = SlotState.EMPTY
var grow_time: float = 10.0
var current_time: float = 0.0
var reward: int = 1

@onready var status_label = $Column/StatusLabel
@onready var progress_bar = $Column/ProgressBar
@onready var action_button = $Column/ActionButton

func _ready() -> void:
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
		SlotState.EMPTY:
			plant()
		SlotState.GROWING:
			pass
		SlotState.READY:
			harvest()

func plant() -> void:
	state = SlotState.GROWING
	current_time = 0.0
	update_ui()

func harvest() -> void:
	state = SlotState.EMPTY
	current_time = 0.0
	harvested.emit(reward)
	update_ui()

func update_ui() -> void:
	match state:
		SlotState.EMPTY:
			status_label.text = "Empty Slot"
			action_button.text = "Plant"
			progress_bar.value = 0
		SlotState.GROWING:
			status_label.text = "Growing..."
			action_button.text = "Waiting"
			progress_bar.value = (current_time / grow_time) * 100.0
		SlotState.READY:
			status_label.text = "Ready for harvest"
			action_button.text = "Harvest"
			progress_bar.value = 100
