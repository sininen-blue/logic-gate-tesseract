extends Panel

const TRUTH_TABLE_ROW = preload("res://ui/components/truth_table_row.tscn")
const DARK_PANEL = preload("res://ui/themes/darkPanel.tres")
const LIGHT_PANEL = preload("res://ui/themes/lightPanel.tres")

const LEFT_ARROW = preload("res://assets/UI/icons/left-arrow.png")
const RIGHT_ARROW = preload("res://assets/UI/icons/right-arrow.png")

var close_pos: Vector2 = Vector2(1141, 135)
var open_pos: Vector2 = Vector2(867, 135)
var opened: bool = false

var output_count: int
var input_count: int

@onready var handle_button: Button = $HandleButton
@onready var debounce_timer: Timer = $DebounceTimer
@onready var truth_table_heading: Panel = $TruthTableHeading
@onready var truth_table: VBoxContainer = $TruthTableScroll/TruthTable


func _ready() -> void:
	if DataManager.player_save["seen_simulation_tutorial"] == false:
		_on_handle_button_pressed()
	
	self.position = close_pos
	
	var level_data : Dictionary = DataManager.current_level.data
	
	output_count = int(level_data["end_count"])
	input_count = len(level_data["truth_table"][0]) - output_count
	
	truth_table_heading.clear()
	var heading_count: int = 0
	for input in input_count:
		truth_table_heading.variables += String.chr(65  + heading_count)
		heading_count += 1
	for output in output_count:
		truth_table_heading.outputs += String.chr(65  + heading_count)
		heading_count += 1
	truth_table_heading.set_data()
	
	# remove current data
	var truth_table_rows: Array[Node] = truth_table.get_children()
	for row in truth_table_rows:
		truth_table.remove_child(row)
	
	var row_count: int = 0
	for row : String in level_data["truth_table"]:
		var new_row: Panel = TRUTH_TABLE_ROW.instantiate()
		new_row.variables = row.left(input_count)
		new_row.outputs = row.right(output_count)
		
		if row_count % 2 == 0:
			new_row.theme = DARK_PANEL
		else:
			new_row.theme = LIGHT_PANEL
		row_count += 1
		truth_table.add_child(new_row)


func set_row_checks(results_table: Array[String]) -> void:
	var target_table: Array[Node] = truth_table.get_children()
	
	for index in len(results_table):
		var target_outputs: String = target_table[index].outputs.right(output_count)
		var results_outputs: String = results_table[index].right(output_count)
		if target_outputs == results_outputs:
			target_table[index].checked = true


func _on_handle_button_pressed() -> void:
	if debounce_timer.is_stopped():
		if opened:
			opened = false
			handle_button.icon = LEFT_ARROW
			tween_position(close_pos)
		else:
			opened = true
			handle_button.icon = RIGHT_ARROW
			tween_position(open_pos)
	
	debounce_timer.start()


func tween_position(to: Vector2) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", to, 1.5)
