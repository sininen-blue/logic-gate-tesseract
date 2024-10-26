extends Line2D
class_name Connection

var output : Gate # start
var input : Gate # end

var distance : float = 30
var index : int = 0
var area_pool : Array[Area2D]

@onready var manager : Node2D = get_parent()

func _ready() -> void:
	self.default_color = Color("#1e1e1e")
	self.width = 6
	self.joint_mode = Line2D.LINE_JOINT_ROUND
	self.begin_cap_mode = Line2D.LINE_CAP_ROUND
	self.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	self.add_point(output.output_area.global_position)
	self.add_point(input.input_area.global_position)
	
	distribute_points()
	distribute_areas()


func _process(_delta: float) -> void:
	self.set_point_position(0, output.output_area.global_position)
	self.set_point_position(get_point_count()-1, input.input_area.global_position)
	
	distribute_points()
	distribute_areas()
	
	if len(area_pool) < self.get_point_count():
		var area : Area2D = create_area(points[0])
		area_pool.append(area)
		self.add_child(area)
	if len(area_pool) > self.get_point_count():
		var area : Area2D = area_pool.pop_back()
		self.remove_child(area)


func distribute_areas() -> void:
	if len(area_pool) != get_point_count():
		return
	
	for j in range(len(area_pool)):
		area_pool[j].global_position = points[j]


func distribute_points() -> void:
	var unit_vec : Vector2 = points[0].direction_to(points[-1])
	var pointer : Vector2 = points[0]
	var vectors : PackedVector2Array
	
	while pointer.distance_to(points[-1]) > distance:
		pointer = pointer + (unit_vec * distance)
		vectors.append(pointer)
	
	vectors.insert(0, points[0])
	vectors.append(points[-1])
	
	points = vectors

func create_area(target : Vector2) -> Area2D:
	var area : Area2D = Area2D.new()
	area.global_position = target
	area.add_to_group("connections")
	
	var collision : CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = 20
	
	collision.shape = shape
	area.add_child(collision)
	
	return area
