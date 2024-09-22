extends VBoxContainer

@export var formula_label: PackedScene

var roots: Array[logic_node]
class logic_node:
	var gate: Gate
	var left: logic_node = null
	var right: logic_node = null

func new_node(gate: Gate) -> logic_node:
	var node: logic_node = logic_node.new()
	node.gate = gate
	
	if roots.is_empty():
		roots.append(node)
	else:
		## TODO: should just have a function where it checks if
		## it shouild be a new root
		## or if it choul be a child of a root
		for root in roots:
			## I can't check becuase I never put root.left or root.right
			## it shoudl be root.left.gate
			if root.left.gate == node.gate or root.right.gate == node.gate:
				print("shouldn't be root")
				continue
			else:
				roots.append(node)
				break
	## NOTE: f shouldn't be a null
	## I think it's because I don't check upwards
	## so It'll only work if I already have f
	## and then make e
	
	# this seems dumb
	## TODO: new plan, walk from start gates only
	for connection in node.gate.input_connections:
		if connection.output.gate_type == "start":
			var child_node: logic_node = logic_node.new()
			child_node.gate = connection.output
			if node.left == null:
				node.left = child_node
				continue
			node.right = child_node
	
	## testing
	print(roots)
	for root in roots:
		print(root.gate.gate_name, root.left, root.right)
	
	
	return node


func walk(curr: logic_node, path: Array[logic_node]) -> Array[logic_node]:
	if curr == null:
		return path
	
	path.append(curr)
	
	# NOTE: doesn't work with not and end gates
	walk(curr.left, path)
	walk(curr.right, path)
	
	return path

# what do I want to happen
# when a connection is made
# check if the input of that connection has the maximum amount of connections
# that means that it's a "working" gate
# then make a logic_node out of that, and then add that to an array
# then check if that gates children is a start gate
# if so add that to the children of the child node

# if a new logic_node is made, check to see if the children of that node, include
# the gate of one of the root nodes, if so, combine

# also if a connection is deleted
# remove the logic_node associated with the input of that connection
# also move the root around
