extends Node2D


const TRASH_BIN_OPEN = preload("res://assets/simulation/trashBin/trashBin-open.png")
const TRASH_BIN = preload("res://assets/simulation/trashBin/trashBin.png")
const MAX_TEST_COUNT: int = 3

enum {
	IDLE,
	MOVING_CAMERA,
	MOVING_GATE,
	CREATING_CONNECTION,
}
var state : int = IDLE

var simulation_running: bool = false

var all_gates : Array[Gate]
var start_gates : Array[Gate]
var end_gates : Array[Gate]

var mouse_in_trash_bin: bool = false
var time_spent: int = 0
var test_count: int = MAX_TEST_COUNT

@export var GATE_SCENE : PackedScene
@onready var LEVEL : JSON = DataManager.current_level

@onready var temp_line: Line2D = $TempLine
@onready var mouse_area: Area2D = $MouseArea
@onready var camera : Camera2D = $Camera2D

@onready var trash_sprite: Sprite2D = $CanvasLayer/UI/FlowContainer/TrashContainer/Control/TrashSprite

@onready var formula_container: VBoxContainer = $CanvasLayer/UI/FormulaContainer

@onready var and_button: Button = $CanvasLayer/UI/FlowContainer/AndButton
@onready var or_button: Button = $CanvasLayer/UI/FlowContainer/OrButton
@onready var xor_button: Button = $CanvasLayer/UI/FlowContainer/XorButton
@onready var nand_button: Button = $CanvasLayer/UI/FlowContainer/NandButton
@onready var nor_button: Button = $CanvasLayer/UI/FlowContainer/NorButton
@onready var xnor_button: Button = $CanvasLayer/UI/FlowContainer/XnorButton
@onready var not_button: Button = $CanvasLayer/UI/FlowContainer/NotButton
@onready var run_button: Button = $CanvasLayer/UI/RunButton
@onready var button_container: FlowContainer = $CanvasLayer/UI/FlowContainer

@onready var side_truth_table: Panel = $CanvasLayer/UI/SideTruthTable
@onready var test_run_button: Button = $CanvasLayer/UI/TestRunButton
@onready var test_count_label: Label = $CanvasLayer/UI/TestRunButton/TestCountLabel

func _ready() -> void:
	randomize()
	and_button.button_down.connect(create_gate.bind("and"))
	or_button.button_down.connect(create_gate.bind("or"))
	xor_button.button_down.connect(create_gate.bind("xor"))
	nand_button.button_down.connect(create_gate.bind("nand"))
	nor_button.button_down.connect(create_gate.bind("nor"))
	xnor_button.button_down.connect(create_gate.bind("xnor"))
	not_button.button_down.connect(create_gate.bind("not"))
	
	run_button.pressed.connect(run_simulation)
	
	create_level()
	
	if DataManager.auto_generate_level == true:
		generate_circuit()
		DataManager.auto_generate_level = false


func create_level() -> void:
	var level_data : Dictionary = LEVEL.data
	var truth_table : Array = level_data["truth_table"]
	var end_count : int = int(level_data["end_count"])
	var start_count : int = truth_table[0].length() - end_count
	
	for start in range(start_count):
		create_gate("start", "left")
	for end in range(end_count):
		create_gate("end", "right")
	
	if level_data.has("allow") == false:
		return
	
	for button in button_container.get_children():
		if button is not Button:
			break
		button.disabled = true
	
	for gate: String in level_data["allow"]:
		match gate:
			"and":
				and_button.disabled = false
			"or":
				or_button.disabled = false
			"xor":
				xor_button.disabled = false
			"nand":
				nand_button.disabled = false
			"nor":
				nor_button.disabled = false
			"xnor":
				xnor_button.disabled = false
			"not":
				not_button.disabled = false


func generate_circuit() -> void:
	var truth_table: Array = LEVEL.data["truth_table"]
	var output_count: int = int(LEVEL.data["end_count"])
	var input_count: int = len(truth_table[0]) - output_count
	var minterms: Array
	
	for row: String in truth_table:
		if row.right(output_count) == "1":
			minterms.append(row.left(input_count))
	
	var sop: Array
	for term in minterms:
		var product: Array
		
		var count: int = 0
		for variable in term:
			if variable == "1":
				product.append(str(count))
			if variable == "0":
				product.append(str("!", count))
			count += 1
		sop.append(product)
	
	print(sop)
	var sop_and_gate_list: Array[Gate] = []
	var row: int = 0
	for product in sop:
		var local_and_gate_list: Array[Gate] = []
		if len(product) == 2:
			create_gate("and", "generated", row)
			local_and_gate_list.append(all_gates[-1])
			sop_and_gate_list.append(all_gates[-1])
		if len(product) > 2:
			local_and_gate_list = generate_and_gates(len(product)-1)
			sop_and_gate_list.append(local_and_gate_list[0])
		
		var variable_count: int = 0
		for variable in product:
			var and_index: int = 0
			if len(product) == 3:
				# after the first one, use the second and
				if variable_count > 0:
					and_index = 1
			
			if variable[0] == "!":
				create_gate("not", "generated not", row)
				manual_connection(start_gates[int(variable[1])], all_gates[-1])
				manual_connection(all_gates[-1], local_and_gate_list[and_index])
			else:
				manual_connection(start_gates[int(variable[0])], local_and_gate_list[and_index])
			variable_count += 1
		row+= 1
	
	# or together here
	if len(sop_and_gate_list) == 1:
		manual_connection(sop_and_gate_list[0], end_gates[0])
	elif len(sop_and_gate_list) == 2:
		create_gate("or", "generated", row)
		var or_gate: Gate = all_gates[-1]
		
		for and_gate in sop_and_gate_list:
			manual_connection(and_gate, or_gate)
	else:
		var or_gate_list: Array[Gate] = generate_or_gates(len(sop_and_gate_list)-1)
		manual_connection(sop_and_gate_list[0], or_gate_list[0])
		
		# -1 to account for the first or gate generated
		for i in range(len(or_gate_list)):
			manual_connection(sop_and_gate_list[i+1], or_gate_list[i])
		
		manual_connection(or_gate_list[-1], end_gates[0])
	
	# blast everything here
	var not_column: float = 250
	var not_count: int = 0
	var and_column: float = 450
	var and_count: int = 0
	var or_column: float = 650
	var or_count: int = 0
	for gate in all_gates:
		if gate.gate_type == "end":
			continue
		
		match gate.gate_type:
			"not":
				gate.position = Vector2(not_column, 150 * not_count)
				not_count += 1
			"and":
				gate.position = Vector2(and_column, 150 * and_count)
				and_count += 1
			"or":
				gate.position = Vector2(or_column, 150 * or_count)
				or_count += 1

func manual_connection(output: Gate, input: Gate) -> void:
	temp_connection = Connection.new()
	temp_connection.output = output
	temp_connection.input = input
	complete_connection()


# assumes 3 or more inputs
func generate_or_gates(amount: int) -> Array[Gate]:
	var or_gate_list: Array[Gate]
	var row: int = 0
	
	create_gate("or", "generated or", row)
	or_gate_list.append(all_gates[-1])
	row += 1
	for i in range(amount-1):
		create_gate("or", "generated or", row)
		or_gate_list.append(all_gates[-1])
		
		manual_connection(all_gates[-2], all_gates[-1])
		row += 1
	
	return or_gate_list

func generate_and_gates(amount: int) -> Array[Gate]:
	var and_gate_list: Array[Gate]
	var row: int = 0
	
	create_gate("and", "generated", row)
	and_gate_list.append(all_gates[-1])
	row += 1
	for i in range(amount-1):
		create_gate("and", "generated and", row)
		and_gate_list.append(all_gates[-1])
		
		manual_connection(all_gates[-1], all_gates[-2])
		row += 1
	
	return and_gate_list


## TODO: change the random creaton thing and just have set positions
func create_gate(type : String, location : String = "", count: float = 0) -> void:
	var gate_scene : Gate = GATE_SCENE.instantiate()
	gate_scene.gate_type = type
	gate_scene.gate_name = String.chr(97 + len(all_gates)) # NOTE: will die after Z
	
	var start_location : Vector2
	if location == "left":
		start_location = Vector2(0, 200*len(start_gates))
	elif location == "right":
		start_location = Vector2(1000, 200*len(end_gates))
	elif location == "generated not":
		start_location = Vector2(300, 200*count)
	elif location == "generated and":
		start_location = Vector2(450, 200*count)
	elif location == "generated":
		start_location = Vector2(550, 200*count)
	elif location == "generated or":
		start_location = Vector2(700, 200*count)
	else:
		start_location = Vector2(randi_range(400, 500), randi_range(400, 500))
	gate_scene.global_position = start_location
	
	gate_scene.mouse_near.connect(_on_mouse_near_gate)
	add_child(gate_scene)
	all_gates.append(gate_scene)
	if gate_scene.gate_type == "start":
		start_gates.append(gate_scene)
	if gate_scene.gate_type == "end":
		end_gates.append(gate_scene)
	
	if Input.is_action_pressed("left_click"):
		self._on_mouse_near_gate(gate_scene)
		gate_held = gate_scene
		state = MOVING_GATE


func _on_mouse_near_gate(gate: Gate) -> void:
	match state:
		IDLE:
			match gate.gate_type:
				"start":
					gate.show_output_indicator()
				"end":
					if len(gate.input_connections) < gate.input_max:
						gate.show_input_indictor()
				_:
					if len(gate.input_connections) < gate.input_max:
						gate.show_input_indictor()
					gate.show_output_indicator()
			
		CREATING_CONNECTION:
			if temp_connection.input == null:
				if temp_connection.output == gate:
					return
				if len(gate.input_connections) >= gate.input_max:
					return
				gate.show_input_indictor()
			if temp_connection.output == null:
				if temp_connection.input == gate:
					return
				gate.show_output_indicator()


## Deletion
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	
	if event.is_action_pressed("right_click") and mouse_area.has_overlapping_areas():
		remove_item()
	
	if event.is_action_pressed("mouse_wheel_up"):
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(camera, "zoom", camera.zoom + Vector2(0.2, 0.2), 0.1)
	if event.is_action_pressed("mouse_whee_down") and camera.zoom >= Vector2(0.5, 0.5):
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(camera, "zoom", camera.zoom - Vector2(0.2, 0.2), 0.1)


func remove_item() -> void:
	var areas : Array[Area2D] = mouse_area.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("connections"):
			delete_connection(area.get_parent())
			return
		if area.is_in_group("gates"):
			if !(area.gate_type == "start" or area.gate_type == "end"):
				var to_delete : Array[Connection]
				for connection : Connection in area.connections:
					to_delete.append(connection)
				for connection in to_delete:
					delete_connection(connection)
				remove_child(area)
				return


func delete_connection(connection : Connection) -> void:
	# erase from gate array
	connection.output.connections.erase(connection)
	connection.input.connections.erase(connection)
	connection.input.input_connections.erase(connection)
	
	var gate: Gate = connection.input
	formula_container.delete_node(gate)
	
	# frees node
	remove_child(connection)


func complete_connection() -> void:
	# limits connection inputs
	if len(temp_connection.input.input_connections) >= temp_connection.input.input_max:
		return
	
	var conn_exists: bool = false
	for connection in temp_connection.output.connections:
		if (connection.input == temp_connection.input and
			connection.output == temp_connection.output):
			conn_exists = true
			break
	
	if conn_exists:
		temp_connection.input.shake()
		temp_connection.output.shake()
		return
	
	temp_connection.output.connections.append(temp_connection)
	temp_connection.input.connections.append(temp_connection)
	temp_connection.input.input_connections.append(temp_connection)
	
	add_child(temp_connection)
	
	temp_connection.input.bump()
	temp_connection.output.bump()
	
	var gate: Gate = temp_connection.input
	if len(gate.input_connections) == gate.input_max:
		formula_container.new_node(gate)


## Processes
var start_position : Vector2
var gate_offset : Vector2
var gate_held : Gate
var temp_connection : Connection
func _process(_delta: float) -> void:
	mouse_area.global_position = get_global_mouse_position()
	
	match state:
		IDLE:
			## transitions
			if Input.is_action_just_pressed("left_click"):
				if mouse_area.has_overlapping_areas() == false:
					start_position = get_global_mouse_position()
					state = MOVING_CAMERA
				
				var areas : Array[Area2D] = mouse_area.get_overlapping_areas()
				for area in areas:
					if area.is_in_group("gates"):
						gate_held = area
						gate_offset = area.global_position - get_global_mouse_position()
						state = MOVING_GATE
						break
					
					## Transition to creating connections state
					if area.is_in_group("outputs") or area.is_in_group("inputs"):
						temp_connection = Connection.new()
						
						var gate : Gate = area.get_parent()
						if area.is_in_group("outputs"):
							if gate.gate_type == "end":
								break
							temp_connection.output = gate
							temp_line.points[0] = gate.output_area.global_position
						elif area.is_in_group("inputs"):
							if gate.gate_type == "start":
								break
							temp_connection.input = gate
							temp_line.points[0] = gate.input_area.global_position
						
						temp_line.points[-1] = get_global_mouse_position()
						temp_line.visible = true
						state = CREATING_CONNECTION
						break
		MOVING_CAMERA:
			var mouse_vector : Vector2 = start_position - get_global_mouse_position()
			
			var tween : Tween = get_tree().create_tween()

			tween.set_trans(Tween.TRANS_QUART)
			tween.tween_property(
				camera, "global_position", camera.global_position + mouse_vector, 0.05
			)
			
			if Input.is_action_just_released("left_click"):
				state = IDLE
		
		MOVING_GATE:
			gate_held.global_position = get_global_mouse_position() + gate_offset
			
			if Input.is_action_just_released("left_click"):
				if mouse_in_trash_bin:
					remove_item()
				state = IDLE
		
		CREATING_CONNECTION:
			temp_line.points[-1] = get_global_mouse_position()
			
			if Input.is_action_just_released("left_click"):
				temp_line.visible = false
				
				var input_null: bool = temp_connection.input == null
				var output_null: bool = temp_connection.output == null
				var valid_connection: bool = false
				for area in mouse_area.get_overlapping_areas():
					if temp_connection.input == null and area.is_in_group("inputs"):
						temp_connection.input = area.get_parent()
					if temp_connection.output == null and area.is_in_group("outputs"):
						temp_connection.output = area.get_parent()
					
					if (temp_connection.input != temp_connection.output and
						temp_connection.input != null and
						temp_connection.output != null):
						valid_connection = true
						complete_connection()
						break
				
				state = IDLE
				
				# makes the gate connected to re open indicators
				# assumes the input side is the "end" of the connection
				if valid_connection:
					if input_null:
						temp_connection.input._on_mouse_area_mouse_exited()
						_on_mouse_near_gate(temp_connection.input)
					if output_null:
						temp_connection.output._on_mouse_area_mouse_exited()
						_on_mouse_near_gate(temp_connection.output)
				temp_connection = null


var switch_inverval: float = .5
func run_simulation() -> void:
	if simulation_running:
		switch_inverval = .05
		return
	
	run_button.text = "Skip"
	
	# set speed value
	DataManager.level_clear_speed = time_spent
	
	simulation_running = true
	var truth_table : Array[Array] = generate_truth_table(len(start_gates))
	var end_values : Array[String]
	for row in truth_table:
		for i in range(len(start_gates)):
			start_gates[i].value = row[i]
		
		await get_tree().create_timer(switch_inverval).timeout
		
		var row_results : Array
		for start in start_gates:
			row_results.append(str(start.value))
		for end in end_gates:
			row_results.append(str(end.value))
		end_values.append("".join(row_results))
	
	var json_string : String= JSON.stringify(end_values)
	var file : FileAccess = FileAccess.open("user://temp.dat", FileAccess.WRITE)
	file.store_string(json_string)
	
	get_tree().change_scene_to_file("res://ui/level_complete.tscn")


func _on_test_run_button_pressed() -> void:
	test_count -= 1
	test_count_label.text = str(test_count,"/",MAX_TEST_COUNT)
	
	var truth_table : Array[Array] = generate_truth_table(len(start_gates))
	var end_values : Array[String]
	for row in truth_table:
		for i in range(len(start_gates)):
			start_gates[i].value = row[i]
		
		await get_tree().create_timer(.1).timeout
		
		var row_results : Array
		for start in start_gates:
			row_results.append(str(start.value))
		for end in end_gates:
			row_results.append(str(end.value))
		end_values.append("".join(row_results))
	
	for start in start_gates:
		start.value = 0
	
	side_truth_table.set_row_checks(end_values)
	
	if test_count <= 0:
		test_run_button.disabled = true
		test_count_label.text = str(0,"/",MAX_TEST_COUNT)



func generate_truth_table(start_count : int) -> Array[Array]:
	var num_rows : int = int(pow(2, start_count))
	var output : Array[Array]
	
	for i in range(num_rows):
		var row : Array
		for j in range(start_count):
			var bit_value : int = (i >> j) & 1
			row.append(bit_value)
		row.reverse()
		output.append(row)
	
	return output

func _on_info_button_pressed() -> void:
	$CanvasLayer/UI/LevelInfo.visible = true


func _on_back_button_pressed() -> void:
	if DataManager.is_custom == true:
		get_tree().change_scene_to_file("uid://bwlvlfljyekts")
	else:
		get_tree().change_scene_to_file("uid://yrih2e5sant0")


func _on_control_mouse_entered() -> void:
	trash_sprite.scale = Vector2(1, 1)
	trash_sprite.texture = TRASH_BIN_OPEN
	mouse_in_trash_bin = true


func _on_trash_container_mouse_exited() -> void:
	trash_sprite.scale = Vector2(.7, .7)
	trash_sprite.texture = TRASH_BIN
	mouse_in_trash_bin = false


func _on_timer_timeout() -> void:
	time_spent += 1


func _on_auto_generate_button_pressed() -> void:
	$ConfirmationDialog.visible = true


func _on_confirmation_dialog_confirmed() -> void:
	DataManager.auto_generate_level = true
	get_tree().reload_current_scene()
