extends Line2D
class_name ConnectionLine

var start_point : Vector2
var end_point : Vector2

var distance : float = 30
var index : int = 0

var area_pool : Array[Area2D]

func _ready() -> void:
	self.width = 6
	self.joint_mode = Line2D.LINE_JOINT_ROUND
	self.begin_cap_mode = Line2D.LINE_CAP_ROUND
	self.end_cap_mode = Line2D.LINE_CAP_ROUND


func _process(_delta: float) -> void:
	start_point = self.points[0]
	end_point = self.points[-1]
	
	distribute_points()
	
	if len(area_pool) < self.get_point_count():
		var area : Area2D = create_area(Vector2(200,200))
		area_pool.append(area)
		self.add_child(area)
	if len(area_pool) > self.get_point_count():
		var area : Area2D = area_pool.pop_back()
		self.remove_child(area)

func distribute_areas():
	for j in range(len(area_pool)):
		area_pool[j].global_position = points[j]

func distribute_points():
	var unit_vec : Vector2 = start_point.direction_to(end_point)
	var pointer : Vector2 = start_point
	var vectors : PackedVector2Array
	
	while pointer.distance_to(end_point) > distance:
		pointer = pointer + (unit_vec * distance)
		vectors.append(pointer)
	
	vectors.insert(0, start_point)
	vectors.append(end_point)
	
	points = vectors

func create_area(target : Vector2) -> Area2D:
	var area : Area2D = Area2D.new()
	area.global_position = target
	
	var collision : CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = 20
	
	collision.shape = shape
	area.add_child(collision)
	
	return area
